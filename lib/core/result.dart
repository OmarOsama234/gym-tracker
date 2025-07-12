import 'exceptions.dart';

/// A Result class that encapsulates success or failure
abstract class Result<T> {
  const Result();
  
  /// Check if the result is a success
  bool get isSuccess => this is Success<T>;
  
  /// Check if the result is a failure
  bool get isFailure => this is Failure<T>;
  
  /// Get the data if success, null if failure
  T? get data => switch (this) {
    Success<T> success => success.data,
    Failure<T> _ => null,
  };
  
  /// Get the exception if failure, null if success
  AppException? get exception => switch (this) {
    Success<T> _ => null,
    Failure<T> failure => failure.exception,
  };
  
  /// Transform the result if success, otherwise return failure
  Result<U> map<U>(U Function(T) transform) {
    return switch (this) {
      Success<T> success => Success(transform(success.data)),
      Failure<T> failure => Failure(failure.exception),
    };
  }
  
  /// Chain operations that return Result
  Result<U> flatMap<U>(Result<U> Function(T) transform) {
    return switch (this) {
      Success<T> success => transform(success.data),
      Failure<T> failure => Failure(failure.exception),
    };
  }
  
  /// Handle both success and failure cases
  U fold<U>(
    U Function(T) onSuccess,
    U Function(AppException) onFailure,
  ) {
    return switch (this) {
      Success<T> success => onSuccess(success.data),
      Failure<T> failure => onFailure(failure.exception),
    };
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