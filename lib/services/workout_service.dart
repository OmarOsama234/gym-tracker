import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout.dart';

class WorkoutService {
  final Box<Workout> _workoutBox = Hive.box<Workout>('workouts');

  Future<void> addWorkout(Workout workout) async {
    await _workoutBox.add(workout);
  }

  List<Workout> getAllWorkouts() {
    final workouts = _workoutBox.values.toList();
    workouts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return workouts;
  }

  Future<void> deleteWorkoutAt(int index) async {
    await _workoutBox.deleteAt(index);
  }

  Future<void> deleteWorkout(Workout workout) async {
    await workout.delete();
  }

  // ✅ FIXED: Now recognized after flutter/foundation.dart import
  ValueListenable<Box<Workout>> getWorkoutListenable() {
    return _workoutBox.listenable();
  }
}