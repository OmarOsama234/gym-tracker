import 'dart:async';
import 'package:flutter/material.dart';
import 'constants.dart';

/// Utility class for common helper functions
class Utils {
  /// Show a snackbar with message
  static void showSnackBar(BuildContext context, String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppConstants.defaultPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
    );
  }

  /// Show a confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppConstants.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppConstants.buttonDelete),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Format date to readable string
  static String formatDate(DateTime date) {
    return "${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}";
  }

  /// Format time to readable string
  static String formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  /// Format datetime to readable string
  static String formatDateTime(DateTime dateTime) {
    return "${formatDate(dateTime)} - ${formatTime(dateTime)}";
  }

  /// Format duration to readable string
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return "${minutes}m ${seconds}s";
  }

  /// Get relative time string (e.g., "2 hours ago")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  /// Debounce function calls
  static Function debounce(Function func, Duration delay) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(delay, () => func());
    };
  }
}

