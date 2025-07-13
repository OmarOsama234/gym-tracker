import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout.dart';
import '../models/user.dart';
import '../models/social_post.dart';
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
    
    // Register new model adapters
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(UserRoleAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(SocialPostAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(CommentAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(PostTypeAdapter());
    }
    
    // Open boxes
    await Hive.openBox<Workout>(AppConstants.workoutsBoxName);
    await Hive.openBox(AppConstants.settingsBoxName);
    await Hive.openBox<User>('users');
    await Hive.openBox<SocialPost>('social_posts');
    await Hive.openBox<String>('image_paths');
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
