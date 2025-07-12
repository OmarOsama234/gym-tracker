class AppConstants {
  // App Info
  static const String appName = 'Gym Tracker';
  static const String appVersion = '1.0.0';
  
  // Hive Box Names
  static const String workoutsBoxName = 'workouts';
  static const String settingsBoxName = 'settings';
  
  // Database Type IDs
  static const int workoutTypeId = 0;
  
  // Validation Constants
  static const int minSets = 1;
  static const int maxSets = 50;
  static const int minReps = 1;
  static const int maxReps = 1000;
  static const double minWeight = 0.1;
  static const double maxWeight = 1000.0;
  static const int maxExerciseNameLength = 50;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultSpacing = 12.0;
  static const double buttonHeight = 48.0;
  static const double cardElevation = 2.0;
  static const double borderRadius = 12.0;
  
  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  
  // Error Messages
  static const String errorGeneral = 'An error occurred. Please try again.';
  static const String errorInvalidInput = 'Please enter valid information.';
  static const String errorNetworkConnection = 'Please check your internet connection.';
  static const String errorDataNotFound = 'No data found.';
  
  // Success Messages
  static const String successWorkoutSaved = 'Workout saved successfully!';
  static const String successWorkoutUpdated = 'Workout updated successfully!';
  static const String successWorkoutDeleted = 'Workout deleted successfully!';
  
  // Form Labels
  static const String labelExercise = 'Exercise';
  static const String labelSets = 'Sets';
  static const String labelReps = 'Reps';
  static const String labelWeight = 'Weight (kg)';
  
  // Form Hints
  static const String hintExercise = 'Enter exercise name';
  static const String hintSets = 'Number of sets';
  static const String hintReps = 'Number of reps';
  static const String hintWeight = 'Weight in kg';
  
  // Validation Messages
  static const String validationExerciseRequired = 'Exercise name is required';
  static const String validationExerciseTooLong = 'Exercise name is too long';
  static const String validationSetsRequired = 'Sets number is required';
  static const String validationSetsInvalid = 'Please enter a valid number of sets';
  static const String validationRepsRequired = 'Reps number is required';
  static const String validationRepsInvalid = 'Please enter a valid number of reps';
  static const String validationWeightRequired = 'Weight is required';
  static const String validationWeightInvalid = 'Please enter a valid weight';
  
  // Button Labels
  static const String buttonSave = 'Save Workout';
  static const String buttonUpdate = 'Update';
  static const String buttonCancel = 'Cancel';
  static const String buttonDelete = 'Delete';
  static const String buttonEdit = 'Edit';
  
  // Navigation
  static const String navHistory = 'History';
  static const String navSettings = 'Settings';
  
  // Dialog Titles
  static const String dialogEditWorkout = 'Edit Workout';
  static const String dialogDeleteWorkout = 'Delete Workout';
  static const String dialogDeleteConfirmation = 'Are you sure you want to delete this workout?';
}