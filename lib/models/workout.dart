import 'package:hive/hive.dart';
import '../core/constants.dart';

part 'workout.g.dart';

@HiveType(typeId: AppConstants.workoutTypeId)
class Workout extends HiveObject {
  @HiveField(0)
  String exercise;

  @HiveField(1)
  int sets;

  @HiveField(2)
  int reps;

  @HiveField(3)
  double weight;

  @HiveField(4)
  DateTime timestamp;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  Duration? duration;

  Workout({
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.timestamp,
    this.notes,
    this.duration,
  });

  /// Named constructor for creating a workout from form data
  Workout.fromForm({
    required String exercise,
    required int sets,
    required int reps,
    required double weight,
    String? notes,
    Duration? duration,
  }) : this(
          exercise: exercise.trim(),
          sets: sets,
          reps: reps,
          weight: weight,
          timestamp: DateTime.now(),
          notes: notes?.trim(),
          duration: duration,
        );

  /// Named constructor for creating a copy of an existing workout
  Workout.copy(Workout other)
      : this(
          exercise: other.exercise,
          sets: other.sets,
          reps: other.reps,
          weight: other.weight,
          timestamp: other.timestamp,
          notes: other.notes,
          duration: other.duration,
        );

  /// Factory constructor for creating a workout from JSON
  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      exercise: json['exercise'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      weight: (json['weight'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'] as int)
          : null,
    );
  }

  /// Convert workout to JSON
  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'duration': duration?.inMilliseconds,
    };
  }

  /// Calculate total volume (sets × reps × weight)
  double get totalVolume => sets * reps * weight;

  /// Get formatted date string
  String get formattedDate {
    return "${timestamp.year}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.day.toString().padLeft(2, '0')}";
  }

  /// Get formatted time string
  String get formattedTime {
    return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
  }

  /// Get formatted date and time string
  String get formattedDateTime {
    return "$formattedDate - $formattedTime";
  }

  /// Get formatted duration string
  String get formattedDuration {
    if (duration == null) return 'N/A';
    final minutes = duration!.inMinutes;
    final seconds = duration!.inSeconds % 60;
    return "${minutes}m ${seconds}s";
  }

  /// Get workout summary for display
  String get summary {
    return "$exercise - ${sets}x$reps @ ${weight}kg";
  }

  /// Check if workout is valid
  bool get isValid {
    return exercise.trim().isNotEmpty &&
        exercise.trim().length <= AppConstants.maxExerciseNameLength &&
        sets >= AppConstants.minSets &&
        sets <= AppConstants.maxSets &&
        reps >= AppConstants.minReps &&
        reps <= AppConstants.maxReps &&
        weight >= AppConstants.minWeight &&
        weight <= AppConstants.maxWeight;
  }

  /// Update workout with new values
  void updateWith({
    String? exercise,
    int? sets,
    int? reps,
    double? weight,
    String? notes,
    Duration? duration,
  }) {
    if (exercise != null) this.exercise = exercise.trim();
    if (sets != null) this.sets = sets;
    if (reps != null) this.reps = reps;
    if (weight != null) this.weight = weight;
    if (notes != null) this.notes = notes.trim();
    if (duration != null) this.duration = duration;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Workout &&
          runtimeType == other.runtimeType &&
          exercise == other.exercise &&
          sets == other.sets &&
          reps == other.reps &&
          weight == other.weight &&
          timestamp == other.timestamp &&
          notes == other.notes &&
          duration == other.duration;

  @override
  int get hashCode =>
      exercise.hashCode ^
      sets.hashCode ^
      reps.hashCode ^
      weight.hashCode ^
      timestamp.hashCode ^
      notes.hashCode ^
      duration.hashCode;

  @override
  String toString() {
    return 'Workout(exercise: $exercise, sets: $sets, reps: $reps, weight: $weight, timestamp: $timestamp, notes: $notes, duration: $duration)';
  }
}