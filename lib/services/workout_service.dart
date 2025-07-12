import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout.dart';
import '../core/constants.dart';
import '../core/exceptions.dart';
import '../core/result.dart';

/// Service class for managing workout operations
class WorkoutService {
  static final WorkoutService _instance = WorkoutService._internal();
  factory WorkoutService() => _instance;
  WorkoutService._internal();

  late final Box<Workout> _workoutBox;
  bool _isInitialized = false;

  /// Initialize the service
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      _workoutBox = Hive.box<Workout>(AppConstants.workoutsBoxName);
      _isInitialized = true;
    } catch (e) {
      throw DatabaseException('Failed to initialize WorkoutService', e.toString());
    }
  }

  /// Ensure service is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw DatabaseException('WorkoutService not initialized. Call init() first.');
    }
  }

  /// Add a new workout
  Future<Result<void>> addWorkout(Workout workout) async {
    try {
      _ensureInitialized();
      
      if (!workout.isValid) {
        return const Failure(InvalidInputException('Invalid workout data'));
      }
      
      await _workoutBox.add(workout);
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseException('Failed to add workout', e.toString()));
    }
  }

  /// Get all workouts
  Result<List<Workout>> getAllWorkouts() {
    try {
      _ensureInitialized();
      
      final workouts = _workoutBox.values.toList();
      workouts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return Success(workouts);
    } catch (e) {
      return Failure(DatabaseException('Failed to get workouts', e.toString()));
    }
  }

  /// Get workouts by date range
  Result<List<Workout>> getWorkoutsByDateRange(DateTime start, DateTime end) {
    try {
      _ensureInitialized();
      
      final workouts = _workoutBox.values
          .where((workout) =>
              workout.timestamp.isAfter(start) && workout.timestamp.isBefore(end))
          .toList();
      
      workouts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return Success(workouts);
    } catch (e) {
      return Failure(DatabaseException('Failed to get workouts by date range', e.toString()));
    }
  }

  /// Get workouts by exercise name
  Result<List<Workout>> getWorkoutsByExercise(String exerciseName) {
    try {
      _ensureInitialized();
      
      final workouts = _workoutBox.values
          .where((workout) => 
              workout.exercise.toLowerCase().contains(exerciseName.toLowerCase()))
          .toList();
      
      workouts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return Success(workouts);
    } catch (e) {
      return Failure(DatabaseException('Failed to get workouts by exercise', e.toString()));
    }
  }

  /// Update an existing workout
  Future<Result<void>> updateWorkout(Workout workout) async {
    try {
      _ensureInitialized();
      
      if (!workout.isValid) {
        return const Failure(InvalidInputException('Invalid workout data'));
      }
      
      await workout.save();
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseException('Failed to update workout', e.toString()));
    }
  }

  /// Delete a workout
  Future<Result<void>> deleteWorkout(Workout workout) async {
    try {
      _ensureInitialized();
      
      if (!workout.isInBox) {
        return const Failure(DataNotFoundException('Workout not found in database'));
      }
      
      await workout.delete();
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseException('Failed to delete workout', e.toString()));
    }
  }

  /// Delete workout at specific index
  Future<Result<void>> deleteWorkoutAt(int index) async {
    try {
      _ensureInitialized();
      
      if (index < 0 || index >= _workoutBox.length) {
        return const Failure(InvalidInputException('Invalid workout index'));
      }
      
      await _workoutBox.deleteAt(index);
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseException('Failed to delete workout', e.toString()));
    }
  }

  /// Clear all workouts
  Future<Result<void>> clearAllWorkouts() async {
    try {
      _ensureInitialized();
      
      await _workoutBox.clear();
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseException('Failed to clear workouts', e.toString()));
    }
  }

  /// Get workout count
  int getWorkoutCount() {
    _ensureInitialized();
    return _workoutBox.length;
  }

  /// Get total volume for all workouts
  double getTotalVolume() {
    _ensureInitialized();
    return _workoutBox.values.fold(0.0, (sum, workout) => sum + workout.totalVolume);
  }

  /// Get total volume for specific exercise
  double getTotalVolumeForExercise(String exerciseName) {
    _ensureInitialized();
    return _workoutBox.values
        .where((workout) => workout.exercise.toLowerCase() == exerciseName.toLowerCase())
        .fold(0.0, (sum, workout) => sum + workout.totalVolume);
  }

  /// Get unique exercise names
  List<String> getUniqueExercises() {
    _ensureInitialized();
    final exercises = _workoutBox.values.map((workout) => workout.exercise).toSet().toList();
    exercises.sort();
    return exercises;
  }

  /// Get workout statistics
  Map<String, dynamic> getWorkoutStatistics() {
    _ensureInitialized();
    
    final workouts = _workoutBox.values.toList();
    if (workouts.isEmpty) {
      return {
        'totalWorkouts': 0,
        'totalVolume': 0.0,
        'uniqueExercises': 0,
        'averageVolume': 0.0,
        'lastWorkoutDate': null,
      };
    }
    
    final totalVolume = workouts.fold(0.0, (sum, workout) => sum + workout.totalVolume);
    final uniqueExercises = workouts.map((w) => w.exercise).toSet().length;
    final lastWorkout = workouts.reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
    
    return {
      'totalWorkouts': workouts.length,
      'totalVolume': totalVolume,
      'uniqueExercises': uniqueExercises,
      'averageVolume': totalVolume / workouts.length,
      'lastWorkoutDate': lastWorkout.timestamp,
    };
  }

  /// Get workout box listenable for reactive UI
  ValueListenable<Box<Workout>> getWorkoutListenable() {
    _ensureInitialized();
    return _workoutBox.listenable();
  }
}