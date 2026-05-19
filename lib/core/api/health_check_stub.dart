import 'api_exception.dart';
import 'api_result.dart';

/// Web y otras plataformas sin `dart:io`.
Future<ApiResult<Map<String, dynamic>>> runBackendHealth(Uri? base) async {
  if (base == null) {
    return ApiResult.failure(
      ApiException(
        'Health check sin URL base configurada',
        code: 'no_backend',
      ),
    );
  }
  return ApiResult.failure(
    ApiException(
      'Comprobación de backend no disponible en esta plataforma de compilación '
      '(use iOS/Android o un objetivo con dart:io)',
      code: 'unsupported_platform',
    ),
  );
}
