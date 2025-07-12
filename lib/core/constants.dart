class AppConstants {
  // App Information
  static const String appName = 'Gym Tracker';
  static const String appVersion = '1.0.0';
  
  // Database Configuration
  static const String workoutsBoxName = 'workouts';
  static const String settingsBoxName = 'settings';
  static const int workoutTypeId = 0;
  
  // Validation Limits
  static const int minSets = 1;
  static const int maxSets = 50;
  static const int minReps = 1;
  static const int maxReps = 1000;
  static const double minWeight = 0.1;
  static const double maxWeight = 1000.0;
  static const int maxExerciseNameLength = 50;
  static const int maxNotesLength = 200;
  
  // UI Dimensions
  static const double defaultPadding = 16.0;
  static const double defaultSpacing = 12.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 24.0;
  static const double buttonHeight = 48.0;
  static const double cardElevation = 2.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  
  // Animation Durations
  static const int defaultAnimationMs = 300;
  static const int shortAnimationMs = 150;
  static const int longAnimationMs = 500;
  
  // Form Labels
  static const String labelExercise = 'Exercise';
  static const String labelSets = 'Sets';
  static const String labelReps = 'Reps';
  static const String labelWeight = 'Weight (kg)';
  static const String labelNotes = 'Notes';
  
  // Form Hints
  static const String hintExercise = 'Enter exercise name';
  static const String hintSets = 'Number of sets';
  static const String hintReps = 'Number of reps';
  static const String hintWeight = 'Weight in kg';
  static const String hintNotes = 'Add notes about this workout';
  
  // Button Labels
  static const String buttonSave = 'Save Workout';
  static const String buttonUpdate = 'Update';
  static const String buttonCancel = 'Cancel';
  static const String buttonDelete = 'Delete';
  static const String buttonEdit = 'Edit';
  static const String buttonClear = 'Clear';
  static const String buttonConfirm = 'Confirm';
  
  // Navigation
  static const String navHome = 'Home';
  static const String navHistory = 'History';
  static const String navSettings = 'Settings';
  
  // Messages - Success
  static const String successWorkoutSaved = 'Workout saved successfully!';
  static const String successWorkoutUpdated = 'Workout updated successfully!';
  static const String successWorkoutDeleted = 'Workout deleted successfully!';
  static const String successAllWorkoutsCleared = 'All workouts cleared successfully!';
  
  // Messages - Error
  static const String errorGeneral = 'An error occurred. Please try again.';
  static const String errorInvalidInput = 'Please enter valid information.';
  static const String errorDatabaseInit = 'Failed to initialize database.';
  static const String errorWorkoutNotFound = 'Workout not found.';
  static const String errorNetworkConnection = 'Please check your internet connection.';
  
  // Validation Messages
  static const String validationExerciseRequired = 'Exercise name is required';
  static const String validationExerciseTooLong = 'Exercise name is too long';
  static const String validationSetsRequired = 'Number of sets is required';
  static const String validationSetsInvalid = 'Please enter a valid number of sets (1-50)';
  static const String validationRepsRequired = 'Number of reps is required';
  static const String validationRepsInvalid = 'Please enter a valid number of reps (1-1000)';
  static const String validationWeightRequired = 'Weight is required';
  static const String validationWeightInvalid = 'Please enter a valid weight (0.1-1000 kg)';
  static const String validationNotesTooLong = 'Notes are too long';
  
  // Dialog Titles
  static const String dialogEditWorkout = 'Edit Workout';
  static const String dialogDeleteWorkout = 'Delete Workout';
  static const String dialogDeleteConfirmation = 'Are you sure you want to delete this workout?';
  static const String dialogClearAllWorkouts = 'Clear All Workouts';
  static const String dialogClearAllConfirmation = 'Are you sure you want to delete all workouts? This action cannot be undone.';
  
  // Empty States
  static const String emptyWorkoutsTitle = 'No workouts logged yet';
  static const String emptyWorkoutsMessage = 'Start your fitness journey by adding your first workout!';
  
  // Statistics
  static const String statsTotal = 'Total Workouts';
  static const String statsVolume = 'Total Volume';
  static const String statsExercises = 'Exercises';
  static const String statsProgress = 'Your Progress';
}