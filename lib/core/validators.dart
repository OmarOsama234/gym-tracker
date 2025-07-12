import 'constants.dart';

/// Utility class for form validation
class Validators {
  /// Validate exercise name
  static String? validateExercise(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.validationExerciseRequired;
    }
    
    if (value.trim().length > AppConstants.maxExerciseNameLength) {
      return AppConstants.validationExerciseTooLong;
    }
    
    return null;
  }
  
  /// Validate sets number
  static String? validateSets(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.validationSetsRequired;
    }
    
    final sets = int.tryParse(value.trim());
    if (sets == null || sets < AppConstants.minSets || sets > AppConstants.maxSets) {
      return AppConstants.validationSetsInvalid;
    }
    
    return null;
  }
  
  /// Validate reps number
  static String? validateReps(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.validationRepsRequired;
    }
    
    final reps = int.tryParse(value.trim());
    if (reps == null || reps < AppConstants.minReps || reps > AppConstants.maxReps) {
      return AppConstants.validationRepsInvalid;
    }
    
    return null;
  }
  
  /// Validate weight
  static String? validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.validationWeightRequired;
    }
    
    final weight = double.tryParse(value.trim());
    if (weight == null || weight < AppConstants.minWeight || weight > AppConstants.maxWeight) {
      return AppConstants.validationWeightInvalid;
    }
    
    return null;
  }
  
  /// Validate multiple fields and return a map of errors
  static Map<String, String> validateWorkout({
    required String exercise,
    required String sets,
    required String reps,
    required String weight,
  }) {
    final errors = <String, String>{};
    
    final exerciseError = validateExercise(exercise);
    if (exerciseError != null) {
      errors['exercise'] = exerciseError;
    }
    
    final setsError = validateSets(sets);
    if (setsError != null) {
      errors['sets'] = setsError;
    }
    
    final repsError = validateReps(reps);
    if (repsError != null) {
      errors['reps'] = repsError;
    }
    
    final weightError = validateWeight(weight);
    if (weightError != null) {
      errors['weight'] = weightError;
    }
    
    return errors;
  }
}