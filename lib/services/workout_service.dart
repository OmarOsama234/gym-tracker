import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout.dart';
import '../core/constants.dart';
import '../core/exceptions.dart';
import '../core/result.dart';
import '../core/hive_setup.dart';

/// Service class for managing workout operations
class WorkoutService extends ChangeNotifier {
  static final WorkoutService _instance = WorkoutService._internal();
  factory WorkoutService() => _instance;
  WorkoutService._internal();

  Box<Workout>? _workoutBox;
  bool _isInitialized = false;

  /// Initialize the service
  Future<Result<void>> init() async {
    if (_isInitialized) return const Success(null);
    
    try {
      if (!isHiveInitialized()) {
        return const Failure(DatabaseException(
          'Hive not initialized',
          'Please initialize Hive before using WorkoutService',
        ));
      }
      
      _workoutBox = getWorkoutsBox();
      _isInitialized = true;
      notifyListeners();
      
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseException(
        'Failed to initialize WorkoutService', 
        e.toString(),
      ));
    }
  }

  /// Ensure service is initialized
  Result<void> _ensureInitialized() {
    if (!_isInitialized || _workoutBox == null) {
      return const Failure(DatabaseException(
        'WorkoutService not initialized',
        'Call init() first',
      ));
    }
    return const Success(null);
  }

  /// Add a new workout
  Future<Result<void>> addWorkout(Workout workout) async {
    final initResult = _ensureInitialized();
    if (initResult.isFailure) return Failure(initResult.exception!);
    
    try {
      if (!workout.isValid) {
        return Failure(ValidationException(
          'Invalid workout data',
          {'workout': workout.validationErrors.join(', ')},
        ));
      }
      
      await _workoutBox!.add(workout);
      notifyListeners();
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseException(
        'Failed to add workout', 
        e.toString(),
      ));
    }
  }

  /// Get all workouts
  Result<List<Workout>> getAllWorkouts() {
    final initResult = _ensureInitialized();
    if (initResult.isFailure) return Failure(initResult.exception!);
    
    try {
      final workouts = _workoutBox!.values.toList();
      workouts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return Success(workouts);
    } catch (e) {
      return Failure(DatabaseException(
        'Failed to get workouts', 
        e.toString(),
      ));
    }
  }

  /// Get workouts by date range
  Result<List<Workout>> getWorkoutsByDateRange(DateTime start, DateTime end) {
    final initResult = _ensureInitialized();
    if (initResult.isFailure) return Failure(initResult.exception!);
    
    try {
      final workouts = _workoutBox!.values
          .where((workout) =>
              workout.timestamp.isAfter(start.subtract(const Duration(days: 1))) &&
              workout.timestamp.isBefore(end.add(const Duration(days: 1))))
          .toList();
      
      workouts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return Success(workouts);
    } catch (e) {
      return Failure(DatabaseException(
        'Failed to get workouts by date range', 
        e.toString(),
      ));
    }
  }

  /// Get workouts by exercise name
  Result<List<Workout>> getWorkoutsByExercise(String exerciseName) {
    final initResult = _ensureInitialized();
    if (initResult.isFailure) return Failure(initResult.exception!);
    
    try {
      final workouts = _workoutBox!.values
          .where((workout) => 
              workout.exercise.toLowerCase().contains(exerciseName.toLowerCase()))
          .toList();
      
      workouts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return Success(workouts);
    } catch (e) {
      return Failure(DatabaseException(
        'Failed to get workouts by exercise', 
        e.toString(),
      ));
    }
  }

  /// Search workouts
  Result<List<Workout>> searchWorkouts(String query) {
    final initResult = _ensureInitialized();
    if (initResult.isFailure) return Failure(initResult.exception!);
    
    try {
      final workouts = _workoutBox!.values
          .where((workout) => workout.matchesSearch(query))
          .toList();
      
      workouts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return Success(workouts);
    } catch (e) {
      return Failure(DatabaseException(
        'Failed to search workouts', 
        e.toString(),
      ));
    }
  }

  /// Get workouts by category
  Result<List<Workout>> getWorkoutsByCategory(String category) {
    final initResult = _ensureInitialized();
    if (initResult.isFailure) return Failure(initResult.exception!);
    
    try {
      final workouts = _workoutBox!.values
          .where((workout) => 
              workout.category?.toLowerCase() == category.toLowerCase())
          .toList();
      
      workouts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return Success(workouts);
    } catch (e) {
      return Failure(DatabaseException(
        'Failed to get workouts by category', 
        e.toString(),
      ));
    }
  }

  /// Update an existing workout
  Future<Result<void>> updateWorkout(Workout workout) async {
    final initResult = _ensureInitialized();
    if (initResult.isFailure) return Failure(initResult.exception!);
    
    try {
      if (!workout.isValid) {
        return Failure(ValidationException(
          'Invalid workout data',
          {'workout': workout.validationErrors.join(', ')},
        ));
      }
      
      if (!workout.isInBox) {
        return const Failure(DataNotFoundException(
          'Workout not found in database',
          'Cannot update workout that is not in the database',
        ));
      }
      
      await workout.save();
      notifyListeners();
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseException(
        'Failed to update workout', 
        e.toString(),
      ));
    }
  }

  /// Delete a workout
  Future<Result<void>> deleteWorkout(Workout workout) async {
    final initResult = _ensureInitialized();
    if (initResult.isFailure) return Failure(initResult.exception!);
    
    try {
      if (!workout.isInBox) {
        return const Failure(DataNotFoundException(
          'Workout not found in database',
          'Cannot delete workout that is not in the database',
        ));
      }
      
      await workout.delete();
      notifyListeners();
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseException(
        'Failed to delete workout', 
        e.toString(),
      ));
    }
  }

  /// Delete workout at specific index
  Future<Result<void>> deleteWorkoutAt(int index) async {
    final initResult = _ensureInitialized();
    if (initResult.isFailure) return Failure(initResult.exception!);
    
    try {
      if (index < 0 || index >= _workoutBox!.length) {
        return const Failure(InvalidInputException(
          'Invalid workout index',
          'Index must be within valid range',
        ));
      }
      
      await _workoutBox!.deleteAt(index);
      notifyListeners();
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseException(
        'Failed to delete workout', 
        e.toString(),
      ));
    }
  }

  /// Clear all workouts
  Future<Result<void>> clearAllWorkouts() async {
    final initResult = _ensureInitialized();
    if (initResult.isFailure) return Failure(initResult.exception!);
    
    try {
      await _workoutBox!.clear();
      notifyListeners();
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseException(
        'Failed to clear workouts', 
        e.toString(),
      ));
    }
  }

  /// Get workout count
  Result<int> getWorkoutCount() {
    final initResult = _ensureInitialized();
    if (initResult.isFailure) return Failure(initResult.exception!);
    
    try {
      return Success(_workoutBox!.length);
    } catch (e) {
      return Failure(DatabaseException(
        'Failed to get workout count', 
        e.toString(),
      ));
    }
  }

  /// Get total volume for all workouts
  Result<double> getTotalVolume() {
    final initResult = _ensureInitialized();
    if (initResult.isFailure) return Failure(initResult.exception!);
    
    try {
      final total = _workoutBox!.values.fold(0.0, (sum, workout) => sum + workout.totalVolume);
      return Success(total);
    } catch (e) {
      return Failure(DatabaseException(
        'Failed to get total volume', 
        e.toString(),
      ));
    }
  }

  /// Get total volume for specific exercise
  Result<double> getTotalVolumeForExercise(String exerciseName) {
    final initResult = _ensureInitialized();
    if (initResult.isFailure) return Failure(initResult.exception!);
    
    try {
      final total = _workoutBox!.values
          .where((workout) => workout.exercise.toLowerCase() == exerciseName.toLowerCase())
          .fold(0.0, (sum, workout) => sum + workout.totalVolume);
      return Success(total);
    } catch (e) {
      return Failure(DatabaseException(
        'Failed to get total volume for exercise', 
        e.toString(),
      ));
    }
  }

  /// Get unique exercise names
  Result<List<String>> getUniqueExercises() {
    final initResult = _ensureInitialized();
    if (initResult.isFailure) return Failure(initResult.exception!);
    
    try {
      final exercises = _workoutBox!.values
          .map((workout) => workout.exercise)
          .toSet()
          .toList();
      exercises.sort();
      return Success(exercises);
    } catch (e) {
      return Failure(DatabaseException(
        'Failed to get unique exercises', 
        e.toString(),
      ));
    }
  }

  /// Get unique categories
  Result<List<String>> getUniqueCategories() {
    final initResult = _ensureInitialized();
    if (initResult.isFailure) return Failure(initResult.exception!);
    
    try {
      final categories = _workoutBox!.values
          .map((workout) => workout.category)
          .where((category) => category != null)
          .cast<String>()
          .toSet()
          .toList();
      categories.sort();
      return Success(categories);
    } catch (e) {
      return Failure(DatabaseException(
        'Failed to get unique categories', 
        e.toString(),
      ));
    }
  }

  /// Get workout statistics
  Result<Map<String, dynamic>> getWorkoutStatistics() {
    final initResult = _ensureInitialized();
    if (initResult.isFailure) return Failure(initResult.exception!);
    
    try {
      final workouts = _workoutBox!.values.toList();
      if (workouts.isEmpty) {
        return const Success({
          'totalWorkouts': 0,
          'totalVolume': 0.0,
          'uniqueExercises': 0,
          'uniqueCategories': 0,
          'averageVolume': 0.0,
          'averageIntensity': 0.0,
          'lastWorkoutDate': null,
          'workoutsThisWeek': 0,
          'workoutsThisMonth': 0,
        });
      }
      
      final totalVolume = workouts.fold(0.0, (sum, workout) => sum + workout.totalVolume);
      final uniqueExercises = workouts.map((w) => w.exercise).toSet().length;
      final uniqueCategories = workouts
          .map((w) => w.category)
          .where((c) => c != null)
          .toSet()
          .length;
      
      final lastWorkout = workouts.reduce((a, b) => 
          a.timestamp.isAfter(b.timestamp) ? a : b);
      
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final monthAgo = now.subtract(const Duration(days: 30));
      
      final workoutsThisWeek = workouts
          .where((w) => w.timestamp.isAfter(weekAgo))
          .length;
      
      final workoutsThisMonth = workouts
          .where((w) => w.timestamp.isAfter(monthAgo))
          .length;
      
      final workoutsWithDuration = workouts
          .where((w) => w.duration != null && w.duration!.inMinutes > 0)
          .toList();
      
      final averageIntensity = workoutsWithDuration.isEmpty 
          ? 0.0 
          : workoutsWithDuration
              .map((w) => w.intensity)
              .reduce((a, b) => a + b) / workoutsWithDuration.length;
      
      return Success({
        'totalWorkouts': workouts.length,
        'totalVolume': totalVolume,
        'uniqueExercises': uniqueExercises,
        'uniqueCategories': uniqueCategories,
        'averageVolume': totalVolume / workouts.length,
        'averageIntensity': averageIntensity,
        'lastWorkoutDate': lastWorkout.timestamp,
        'workoutsThisWeek': workoutsThisWeek,
        'workoutsThisMonth': workoutsThisMonth,
      });
    } catch (e) {
      return Failure(DatabaseException(
        'Failed to get workout statistics', 
        e.toString(),
      ));
    }
  }

  /// Get workout box listenable for reactive UI
  Result<ValueListenable<Box<Workout>>> getWorkoutListenable() {
    final initResult = _ensureInitialized();
    if (initResult.isFailure) return Failure(initResult.exception!);
    
    try {
      return Success(_workoutBox!.listenable());
    } catch (e) {
      return Failure(DatabaseException(
        'Failed to get workout listenable', 
        e.toString(),
      ));
    }
  }

  /// Export workouts to JSON
  Result<List<Map<String, dynamic>>> exportWorkouts() {
    final workoutsResult = getAllWorkouts();
    if (workoutsResult.isFailure) return Failure(workoutsResult.exception!);
    
    try {
      final jsonList = workoutsResult.data!
          .map((workout) => workout.toJson())
          .toList();
      return Success(jsonList);
    } catch (e) {
      return Failure(ServiceException(
        'Failed to export workouts', 
        e.toString(),
      ));
    }
  }

  /// Import workouts from JSON
  Future<Result<int>> importWorkouts(List<Map<String, dynamic>> jsonList) async {
    final initResult = _ensureInitialized();
    if (initResult.isFailure) return Failure(initResult.exception!);
    
    try {
      int importedCount = 0;
      for (final json in jsonList) {
        try {
          final workout = Workout.fromJson(json);
          if (workout.isValid) {
            await _workoutBox!.add(workout);
            importedCount++;
          }
        } catch (e) {
          // Skip invalid workouts
          continue;
        }
      }
      
      if (importedCount > 0) {
        notifyListeners();
      }
      
      return Success(importedCount);
    } catch (e) {
      return Failure(ServiceException(
        'Failed to import workouts', 
        e.toString(),
      ));
    }
  }

  /// Get service status
  Map<String, dynamic> getServiceStatus() {
    return {
      'initialized': _isInitialized,
      'hive_initialized': isHiveInitialized(),
      'workout_box_open': _workoutBox != null,
      'workout_count': _workoutBox?.length ?? 0,
    };
  }
}