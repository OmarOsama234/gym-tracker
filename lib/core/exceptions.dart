/// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  final String? details;
  
  const AppException(this.message, [this.details]);
  
  @override
  String toString() => 'AppException: $message${details != null ? ' - $details' : ''}';
}

/// Exception for database operations
class DatabaseException extends AppException {
  const DatabaseException(super.message, [super.details]);
}

/// Exception for validation errors
class ValidationException extends AppException {
  final Map<String, String> fieldErrors;
  
  const ValidationException(super.message, [this.fieldErrors = const {}]);
}

/// Exception for network operations
class NetworkException extends AppException {
  final int? statusCode;
  
  const NetworkException(super.message, [this.statusCode, super.details]);
}

/// Exception for data not found
class DataNotFoundException extends AppException {
  const DataNotFoundException(super.message, [super.details]);
}

/// Exception for invalid input
class InvalidInputException extends AppException {
  const InvalidInputException(super.message, [super.details]);
}