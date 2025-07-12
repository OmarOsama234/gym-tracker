import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(WorkoutAdapter());
  await Hive.openBox<Workout>('workouts');
}
