import 'api_exceptions.dart';

/// Every ApiClient call returns this instead of throwing — ViewModels
/// pattern-match on it instead of wrapping every call in try/catch.
sealed class ApiResult<T> {
  const ApiResult();

  bool get isSuccess => this is ApiSuccess<T>;
  bool get isFailure => this is ApiFailure<T>;

  T? get dataOrNull => switch (this) {
    ApiSuccess<T>(data: final d) => d,
    ApiFailure<T>() => null,
  };

  ApiException? get exceptionOrNull => switch (this) {
    ApiSuccess<T>() => null,
    ApiFailure<T>(exception: final e) => e,
  };

  /// Exhaustive handling — mirrors AsyncValue.when() so it feels familiar
  /// alongside Riverpod's AsyncNotifier usage in Phase 2.
  R when<R>({
    required R Function(T data) success,
    required R Function(ApiException exception) failure,
  }) {
    return switch (this) {
      ApiSuccess<T>(data: final d) => success(d),
      ApiFailure<T>(exception: final e) => failure(e),
    };
  }
}

final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);

  final T data;
}

final class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.exception);

  final ApiException exception;
}
