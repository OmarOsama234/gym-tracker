// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gym_tracker/main.dart';

void main() {
  group('MyApp Widget Tests', () {
    testWidgets('MyApp builds without crashing', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify that the app builds successfully by checking for MaterialApp
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Verify that some kind of scaffold or main UI is present
      // (This will work whether the app loads normally or shows an error)
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('ErrorApp displays error message', (WidgetTester tester) async {
      const testError = 'Test error message';
      
      // Build the error app
      await tester.pumpWidget(const ErrorApp(error: testError));
      await tester.pumpAndSettle();

      // Verify that error message is displayed
      expect(find.text('Failed to initialize app'), findsOneWidget);
      expect(find.text(testError), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('ErrorApp has correct styling', (WidgetTester tester) async {
      const testError = 'Test error message';
      
      // Build the error app
      await tester.pumpWidget(const ErrorApp(error: testError));
      await tester.pumpAndSettle();

      // Verify basic structure is present
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });
  });
}
