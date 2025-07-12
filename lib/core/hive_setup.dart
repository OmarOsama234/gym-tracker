import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout.dart';
import '../core/constants.dart';
import '../core/exceptions.dart';

/// Initialize Hive database
Future<void> initHive() async {
  try {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(AppConstants.workoutTypeId)) {
      Hive.registerAdapter(WorkoutAdapter());
    }
    
    // Open boxes
    await Hive.openBox<Workout>(AppConstants.workoutsBoxName);
    await Hive.openBox(AppConstants.settingsBoxName);
  } catch (e) {
    throw DatabaseException('Failed to initialize Hive database', e.toString());
  }
}

/// Close all Hive boxes
Future<void> closeHive() async {
  try {
    await Hive.close();
  } catch (e) {
    throw DatabaseException('Failed to close Hive database', e.toString());
  }
}
