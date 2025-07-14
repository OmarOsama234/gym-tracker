import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme.dart';
import 'core/hive_setup.dart';
import 'core/constants.dart';
import 'services/workout_service.dart';
import 'services/auth_service.dart';
import 'services/social_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => SocialService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, themeProvider, __) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppConstants.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
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

/// Authentication wrapper to handle login flow
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        // Check if user is logged in
        if (authService.isAuthenticated && authService.currentUser != null) {
          return const MainNavigation();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
