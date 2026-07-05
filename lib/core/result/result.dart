/// Lightweight Result type used across the app instead of throwing.
/// Kept dependency-free (no freezed) so `core` has zero external deps.
sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(Failure failure) = Failure_<T>;

  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) {
    final self = this;
    if (self is Success<T>) return success(self.value);
    if (self is Failure_<T>) return failure(self.failure);
    throw StateError('Unreachable');
  }

  T? get valueOrNull => this is Success<T> ? (this as Success<T>).value : null;
  bool get isSuccess => this is Success<T>;
}

final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

final class Failure_<T> extends Result<T> {
  final Failure failure;
  const Failure_(this.failure);
}

enum FailureCode {
  locationPermissionDenied,
  locationUnavailable,
  network,
  notFound,
  database,
  sensorUnavailable,
  unknown,
}

class Failure {
  final FailureCode code;
  final String message;
  const Failure(this.code, this.message);

  @override
  String toString() => 'Failure(${code.name}): $message';
}
