import 'package:hive/hive.dart';
import '../core/constants.dart';
import '../core/utils.dart';

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

  @HiveField(7)
  String? category;

  Workout({
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.timestamp,
    this.notes,
    this.duration,
    this.category,
  });

  /// Create a workout from form data
  factory Workout.fromForm({
    required String exercise,
    required int sets,
    required int reps,
    required double weight,
    String? notes,
    Duration? duration,
    String? category,
  }) {
    return Workout(
      exercise: exercise.trim(),
      sets: sets,
      reps: reps,
      weight: weight,
      timestamp: DateTime.now(),
      notes: notes?.trim().isNotEmpty == true ? notes!.trim() : null,
      duration: duration,
      category: category?.trim().isNotEmpty == true ? category!.trim() : null,
    );
  }

  /// Create a copy of an existing workout
  factory Workout.copy(Workout other) {
    return Workout(
      exercise: other.exercise,
      sets: other.sets,
      reps: other.reps,
      weight: other.weight,
      timestamp: other.timestamp,
      notes: other.notes,
      duration: other.duration,
      category: other.category,
    );
  }

  /// Create a workout from JSON
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
      category: json['category'] as String?,
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
      'category': category,
    };
  }

  /// Calculate total volume (sets × reps × weight)
  double get totalVolume => sets * reps * weight;

  /// Get formatted date string
  String get formattedDate => Utils.formatDate(timestamp);

  /// Get formatted time string
  String get formattedTime => Utils.formatTime(timestamp);

  /// Get formatted date and time string
  String get formattedDateTime => Utils.formatDateTime(timestamp);

  /// Get relative time string
  String get relativeTime => Utils.getRelativeTime(timestamp);

  /// Get formatted duration string
  String get formattedDuration {
    if (duration == null) return 'N/A';
    return Utils.formatDuration(duration!);
  }

  /// Get workout summary for display
  String get summary => '$exercise - ${sets}x$reps @ ${weight}kg';

  /// Get detailed summary
  String get detailedSummary {
    final volumeText = 'Volume: ${Utils.formatNumber(totalVolume)}kg';
    final durationText = duration != null ? ' • Duration: $formattedDuration' : '';
    return '$summary • $volumeText$durationText';
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
        weight <= AppConstants.maxWeight &&
        (notes == null || notes!.length <= AppConstants.maxNotesLength);
  }

  /// Get validation errors
  List<String> get validationErrors {
    final errors = <String>[];
    
    if (exercise.trim().isEmpty) {
      errors.add(AppConstants.validationExerciseRequired);
    } else if (exercise.trim().length > AppConstants.maxExerciseNameLength) {
      errors.add(AppConstants.validationExerciseTooLong);
    }
    
    if (sets < AppConstants.minSets || sets > AppConstants.maxSets) {
      errors.add(AppConstants.validationSetsInvalid);
    }
    
    if (reps < AppConstants.minReps || reps > AppConstants.maxReps) {
      errors.add(AppConstants.validationRepsInvalid);
    }
    
    if (weight < AppConstants.minWeight || weight > AppConstants.maxWeight) {
      errors.add(AppConstants.validationWeightInvalid);
    }
    
    if (notes != null && notes!.length > AppConstants.maxNotesLength) {
      errors.add(AppConstants.validationNotesTooLong);
    }
    
    return errors;
  }

  /// Update workout with new values
  void updateWith({
    String? exercise,
    int? sets,
    int? reps,
    double? weight,
    String? notes,
    Duration? duration,
    String? category,
  }) {
    if (exercise != null) this.exercise = exercise.trim();
    if (sets != null) this.sets = sets;
    if (reps != null) this.reps = reps;
    if (weight != null) this.weight = weight;
    if (notes != null) {
      this.notes = notes.trim().isNotEmpty ? notes.trim() : null;
    }
    if (duration != null) this.duration = duration;
    if (category != null) {
      this.category = category.trim().isNotEmpty ? category.trim() : null;
    }
  }

  /// Check if workout was performed today
  bool get isToday => Utils.isToday(timestamp);

  /// Check if workout was performed yesterday
  bool get isYesterday => Utils.isYesterday(timestamp);

  /// Get display date (Today, Yesterday, or formatted date)
  String get displayDate => Utils.getDisplayDate(timestamp);

  /// Get workout intensity (volume per minute)
  double get intensity {
    if (duration == null || duration!.inMinutes == 0) return 0.0;
    return totalVolume / duration!.inMinutes;
  }

  /// Get workout priority score (for sorting)
  double get priorityScore {
    // Higher score = higher priority
    final volumeScore = totalVolume / 100.0;
    final recentScore = DateTime.now().difference(timestamp).inHours < 24 ? 10.0 : 0.0;
    return volumeScore + recentScore;
  }

  /// Check if workout matches search query
  bool matchesSearch(String query) {
    if (query.trim().isEmpty) return true;
    
    final searchLower = query.toLowerCase().trim();
    return exercise.toLowerCase().contains(searchLower) ||
           (notes?.toLowerCase().contains(searchLower) ?? false) ||
           (category?.toLowerCase().contains(searchLower) ?? false);
  }

  /// Get workout color based on intensity
  int get colorValue {
    if (totalVolume < 500) return 0xFF10B981; // Green - Light
    if (totalVolume < 1000) return 0xFF3B82F6; // Blue - Medium
    if (totalVolume < 2000) return 0xFFF59E0B; // Orange - Heavy
    return 0xFFEF4444; // Red - Very Heavy
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Workout &&
        other.exercise == exercise &&
        other.sets == sets &&
        other.reps == reps &&
        other.weight == weight &&
        other.timestamp == timestamp &&
        other.notes == notes &&
        other.duration == duration &&
        other.category == category;
  }

  @override
  int get hashCode {
    return Object.hash(
      exercise,
      sets,
      reps,
      weight,
      timestamp,
      notes,
      duration,
      category,
    );
  }

  @override
  String toString() {
    return 'Workout(exercise: $exercise, sets: $sets, reps: $reps, '
           'weight: $weight, timestamp: $timestamp, notes: $notes, '
           'duration: $duration, category: $category)';
  }
}