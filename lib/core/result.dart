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
      return Success(transform((this as Success<T>).data));
    } else if (this is Failure<T>) {
      return Failure((this as Failure<T>).exception);
    }
    throw StateError('Unexpected Result type');
  }
  
  /// Chain operations that return Result
  Result<U> flatMap<U>(Result<U> Function(T) transform) {
    if (this is Success<T>) {
      return transform((this as Success<T>).data);
    } else if (this is Failure<T>) {
      return Failure((this as Failure<T>).exception);
    }
    throw StateError('Unexpected Result type');
  }
  
  /// Handle both success and failure cases
  U fold<U>(
    U Function(T) onSuccess,
    U Function(AppException) onFailure,
  ) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).data);
    } else if (this is Failure<T>) {
      return onFailure((this as Failure<T>).exception);
    }
    throw StateError('Unexpected Result type');
  }
}

/// Success result
class Success<T> extends Result<T> {
  final T data;
  
  const Success(this.data);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;
  
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          exception == other.exception;
  
  @override
  int get hashCode => exception.hashCode;
  
  @override
  String toString() => 'Failure($exception)';
}