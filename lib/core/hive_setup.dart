import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout.dart';
import 'constants.dart';
import 'exceptions.dart';

/// Initialize Hive database
Future<void> initHive() async {
  try {
    // Initialize Hive with Flutter support
    await Hive.initFlutter();
    
    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(AppConstants.workoutTypeId)) {
      Hive.registerAdapter(WorkoutAdapter());
    }
    
    // Open required boxes
    await Future.wait([
      Hive.openBox<Workout>(AppConstants.workoutsBoxName),
      Hive.openBox(AppConstants.settingsBoxName),
    ]);
    
    print('Hive database initialized successfully');
  } catch (e) {
    print('Failed to initialize Hive: $e');
    throw DatabaseException(
      AppConstants.errorDatabaseInit,
      'Hive initialization failed: ${e.toString()}',
    );
  }
}

/// Close all Hive boxes
Future<void> closeHive() async {
  try {
    await Hive.close();
    print('Hive database closed successfully');
  } catch (e) {
    print('Failed to close Hive: $e');
    throw DatabaseException(
      'Failed to close database',
      'Hive close failed: ${e.toString()}',
    );
  }
}

/// Get workouts box
Box<Workout> getWorkoutsBox() {
  if (!Hive.isBoxOpen(AppConstants.workoutsBoxName)) {
    throw DatabaseException(
      'Workouts box is not open',
      'Please initialize Hive first',
    );
  }
  return Hive.box<Workout>(AppConstants.workoutsBoxName);
}

/// Get settings box
Box getSettingsBox() {
  if (!Hive.isBoxOpen(AppConstants.settingsBoxName)) {
    throw DatabaseException(
      'Settings box is not open',
      'Please initialize Hive first',
    );
  }
  return Hive.box(AppConstants.settingsBoxName);
}

/// Check if Hive is properly initialized
bool isHiveInitialized() {
  try {
    return Hive.isBoxOpen(AppConstants.workoutsBoxName) &&
           Hive.isBoxOpen(AppConstants.settingsBoxName);
  } catch (e) {
    return false;
  }
}

/// Clear all data (for testing purposes)
Future<void> clearAllData() async {
  try {
    if (isHiveInitialized()) {
      await Future.wait([
        getWorkoutsBox().clear(),
        getSettingsBox().clear(),
      ]);
    }
  } catch (e) {
    throw DatabaseException(
      'Failed to clear all data',
      e.toString(),
    );
  }
}

/// Get database statistics
Map<String, dynamic> getDatabaseStats() {
  try {
    if (!isHiveInitialized()) {
      return {
        'initialized': false,
        'workouts_count': 0,
        'settings_count': 0,
      };
    }
    
    final workoutsBox = getWorkoutsBox();
    final settingsBox = getSettingsBox();
    
    return {
      'initialized': true,
      'workouts_count': workoutsBox.length,
      'settings_count': settingsBox.length,
      'workouts_box_name': AppConstants.workoutsBoxName,
      'settings_box_name': AppConstants.settingsBoxName,
    };
  } catch (e) {
    return {
      'initialized': false,
      'error': e.toString(),
    };
  }
}
