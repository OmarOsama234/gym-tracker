/// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  final String? details;
  
  const AppException(this.message, [this.details]);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppException &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          details == other.details;
  
  @override
  int get hashCode => Object.hash(runtimeType, message, details);
  
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
  
  const ValidationException(super.message, [this.fieldErrors = const {}, super.details]);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationException &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          details == other.details &&
          fieldErrors == other.fieldErrors;
  
  @override
  int get hashCode => Object.hash(runtimeType, message, details, fieldErrors);
  
  @override
  String toString() => 'ValidationException: $message${details != null ? ' - $details' : ''}${fieldErrors.isNotEmpty ? ' - Fields: $fieldErrors' : ''}';
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