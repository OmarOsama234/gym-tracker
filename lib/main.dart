import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme.dart';
import 'core/hive_setup.dart';
import 'core/constants.dart';
import 'services/workout_service.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Hive database
    await initHive();
    
    // Initialize services
    await WorkoutService().init();
    
    runApp(const MyApp());
  } catch (e) {
    // Handle initialization errors
    runApp(ErrorApp(error: e.toString()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (_, themeProvider, __) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppConstants.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}

/// Error app widget to show initialization errors
class ErrorApp extends StatelessWidget {
  final String error;
  
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: AppConstants.defaultSpacing),
                const Text(
                  'Failed to initialize app',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultSpacing),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: AppConstants.defaultSpacing * 2),
                ElevatedButton(
                  onPressed: () {
                    // Restart app
                    main();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}