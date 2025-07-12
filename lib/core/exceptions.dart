/// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  final String? details;
  
  const AppException(this.message, [this.details]);
  
  @override
  String toString() {
    if (details != null) {
      return 'AppException: $message - $details';
    }
    return 'AppException: $message';
  }
}

/// Exception for database operations
class DatabaseException extends AppException {
  const DatabaseException(String message, [String? details]) : super(message, details);
  
  @override
  String toString() => 'DatabaseException: $message${details != null ? ' - $details' : ''}';
}

/// Exception for validation errors
class ValidationException extends AppException {
  final Map<String, String> fieldErrors;
  
  const ValidationException(String message, [this.fieldErrors = const {}]) : super(message);
  
  @override
  String toString() => 'ValidationException: $message';
}

/// Exception for network operations
class NetworkException extends AppException {
  final int? statusCode;
  
  const NetworkException(String message, [this.statusCode, String? details]) : super(message, details);
  
  @override
  String toString() => 'NetworkException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Exception for data not found
class DataNotFoundException extends AppException {
  const DataNotFoundException(String message, [String? details]) : super(message, details);
  
  @override
  String toString() => 'DataNotFoundException: $message';
}

/// Exception for invalid input
class InvalidInputException extends AppException {
  const InvalidInputException(String message, [String? details]) : super(message, details);
  
  @override
  String toString() => 'InvalidInputException: $message';
}

/// Exception for service operations
class ServiceException extends AppException {
  const ServiceException(String message, [String? details]) : super(message, details);
  
  @override
  String toString() => 'ServiceException: $message';
}