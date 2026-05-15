import 'api_exception.dart';

/// Resultado genérico para futuras llamadas de red.
final class ApiResult<T> {
  const ApiResult({
    required this.success,
    this.data,
    this.error,
  });

  factory ApiResult.ok(T data) => ApiResult(success: true, data: data);

  factory ApiResult.err(ApiException error) =>
      ApiResult(success: false, error: error);

  /// Alias legible para éxito.
  factory ApiResult.success(T data) => ApiResult.ok(data);

  /// Alias legible para error.
  factory ApiResult.failure(ApiException error) => ApiResult.err(error);

  final bool success;
  final T? data;
  final ApiException? error;

  bool get isSuccess => success;
  bool get isFailure => !success;
}
