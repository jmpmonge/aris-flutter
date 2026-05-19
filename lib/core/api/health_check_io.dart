import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'api_endpoints.dart';
import 'api_exception.dart';
import 'api_result.dart';

/// Implementación basada en [HttpClient] (solo plataformas con `dart:io`).
Future<ApiResult<Map<String, dynamic>>> runBackendHealth(Uri? base) async {
  if (base == null) {
    return ApiResult.failure(
      ApiException(
        'Health check sin URL base configurada',
        code: 'no_backend',
      ),
    );
  }
  final uri = base.resolve(ApiEndpoints.health);
  final http = HttpClient();
  try {
    final request = await http.getUrl(uri);
    final response = await request.close().timeout(
      const Duration(seconds: 6),
    );
    final raw = await response
        .transform(utf8.decoder)
        .join()
        .timeout(const Duration(seconds: 4));

    if (response.statusCode != 200) {
      return ApiResult.failure(
        ApiException(
          'HTTP ${response.statusCode} en ${ApiEndpoints.health}',
          code: 'http_error',
        ),
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (e) {
      return ApiResult.failure(
        ApiException(
          'Respuesta ${ApiEndpoints.health} no es JSON válido',
          code: 'bad_response',
          cause: e,
        ),
      );
    }

    if (decoded is! Map) {
      return ApiResult.failure(
        ApiException(
          'Respuesta ${ApiEndpoints.health} inesperada (no objeto JSON)',
          code: 'bad_response',
        ),
      );
    }
    final map = Map<String, dynamic>.from(decoded);
    if (map['status'] == 'ok') {
      return ApiResult.success(map);
    }

    return ApiResult.failure(
      ApiException(
        'Respuesta ${ApiEndpoints.health} inesperada',
        code: 'bad_response',
      ),
    );
  } on SocketException catch (e) {
    return ApiResult.failure(
      ApiException(
        'Sin conexión al backend',
        code: 'no_connection',
        cause: e,
      ),
    );
  } on TimeoutException catch (e) {
    return ApiResult.failure(
      ApiException(
        'Tiempo de espera agotado al contactar el backend',
        code: 'timeout',
        cause: e,
      ),
    );
  } on HttpException catch (e) {
    return ApiResult.failure(
      ApiException(
        'Error HTTP',
        code: 'http_transport',
        cause: e,
      ),
    );
  } catch (e) {
    return ApiResult.failure(
      ApiException(
        'Fallo al comprobar ${ApiEndpoints.health}',
        code: 'unknown',
        cause: e,
      ),
    );
  } finally {
    http.close(force: true);
  }
}
