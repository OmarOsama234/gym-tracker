import 'exceptions.dart';

/// A Result class that encapsulates success or failure
abstract class Result<T> {
  const Result();
  
  /// Check if the result is a success
  bool get isSuccess => this is Success<T>;
  
  /// Check if the result is a failure
  bool get isFailure => this is Failure<T>;
  
  /// Get the data if success, null if failure
  T? get data {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    }
    return null;
  }
  
  /// Get the exception if failure, null if success
  AppException? get exception {
    if (this is Failure<T>) {
      return (this as Failure<T>).exception;
    }
    return null;
  }
  
  /// Transform the result if success, otherwise return failure
  Result<U> map<U>(U Function(T) transform) {
    if (this is Success<T>) {
      try {
        return Success<U>(transform((this as Success<T>).data));
      } catch (e) {
        return Failure<U>(ServiceException('Transform failed', e.toString()));
      }
    } else {
      return Failure<U>((this as Failure<T>).exception);
    }
  }
  
  /// Chain operations that return Result
  Result<U> flatMap<U>(Result<U> Function(T) transform) {
    if (this is Success<T>) {
      try {
        return transform((this as Success<T>).data);
      } catch (e) {
        return Failure<U>(ServiceException('FlatMap failed', e.toString()));
      }
    } else {
      return Failure<U>((this as Failure<T>).exception);
    }
  }
  
  /// Handle both success and failure cases
  U fold<U>(
    U Function(T) onSuccess,
    U Function(AppException) onFailure,
  ) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).data);
    } else {
      return onFailure((this as Failure<T>).exception);
    }
  }
  
  /// Execute action if success (returns the result for chaining)
  Result<T> onSuccess(void Function(T) action) {
    if (this is Success<T>) {
      action((this as Success<T>).data);
    }
    return this;
  }
  
  /// Execute action if failure (returns the result for chaining)
  Result<T> onFailure(void Function(AppException) action) {
    if (this is Failure<T>) {
      action((this as Failure<T>).exception);
    }
    return this;
  }
  
  /// Get data or throw exception
  T getOrThrow() {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    } else {
      throw (this as Failure<T>).exception;
    }
  }
  
  /// Get data or return default value
  T getOrDefault(T defaultValue) {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    } else {
      return defaultValue;
    }
  }
}

/// Success result
class Success<T> extends Result<T> {
  final T data;
  
  const Success(this.data);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T> && 
           runtimeType == other.runtimeType && 
           data == other.data;
  }
  
  @override
  int get hashCode => data.hashCode;
  
  @override
  String toString() => 'Success($data)';
}

/// Failure result
class Failure<T> extends Result<T> {
  final AppException exception;
  
  const Failure(this.exception);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure<T> && 
           runtimeType == other.runtimeType && 
           exception == other.exception;
  }
  
  @override
  int get hashCode => exception.hashCode;
  
  @override
  String toString() => 'Failure($exception)';
}

/// Convenience methods for creating Results
class ResultFactory {
  /// Create a success result
  static Result<T> success<T>(T data) => Success<T>(data);
  
  /// Create a failure result
  static Result<T> failure<T>(AppException exception) => Failure<T>(exception);
  
  /// Create a result from a nullable value
  static Result<T> fromNullable<T>(T? value, String errorMessage) {
    if (value != null) {
      return Success<T>(value);
    } else {
      return Failure<T>(DataNotFoundException(errorMessage));
    }
  }
  
  /// Execute a function and wrap the result
  static Result<T> execute<T>(T Function() function) {
    try {
      return Success<T>(function());
    } catch (e) {
      if (e is AppException) {
        return Failure<T>(e);
      } else {
        return Failure<T>(ServiceException('Execution failed', e.toString()));
      }
    }
  }
  
  /// Execute an async function and wrap the result
  static Future<Result<T>> executeAsync<T>(Future<T> Function() function) async {
    try {
      final result = await function();
      return Success<T>(result);
    } catch (e) {
      if (e is AppException) {
        return Failure<T>(e);
      } else {
        return Failure<T>(ServiceException('Async execution failed', e.toString()));
      }
    }
  }
}