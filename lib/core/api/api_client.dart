import 'api_endpoints.dart';
import 'api_exception.dart';
import 'api_result.dart';

/// Cliente HTTP **no operativo** en v0.37.
///
/// Cuando exista backend:
/// - configurar `baseUrl` y cliente (`dart:io` HttpClient, `package:http`, etc.);
/// - sustituir implementaciones de [get], [post], [patch] por red real;
/// - mappear códigos HTTP y cuerpos JSON a [ApiResult] / [ApiException].
///
/// **Ahora mismo:** ningún método abre sockets ni parsea TLS. Devuelve fallo
/// estable para pruebas de contrato sin servicio.
final class ApiClient {
  ApiClient({Uri? baseUrl}) : _baseUrl = baseUrl;

  final Uri? _baseUrl;

  /// `true` cuando haya URL base y política de red definida (futuro).
  bool get isConfigured => _baseUrl != null;

  Uri? get baseUrl => _baseUrl;

  /// Instancia de demostración sin host (siempre [isConfigured] == false).
  factory ApiClient.provisional() => ApiClient();

  /// GET genérico — **sin** implementación de red hoy.
  Future<ApiResult<Map<String, dynamic>>> get(
    String path, {
    Map<String, String>? query,
  }) async {
    return ApiResult.failure(
      ApiException(
        'GET no disponible: sin backend configurado ($path)',
        code: 'no_backend',
      ),
    );
  }

  /// POST genérico — **sin** implementación de red hoy.
  Future<ApiResult<Map<String, dynamic>>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return ApiResult.failure(
      ApiException(
        'POST no disponible: sin backend configurado ($path)',
        code: 'no_backend',
      ),
    );
  }

  /// PATCH genérico — **sin** implementación de red hoy.
  Future<ApiResult<Map<String, dynamic>>> patch(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return ApiResult.failure(
      ApiException(
        'PATCH no disponible: sin backend configurado ($path)',
        code: 'no_backend',
      ),
    );
  }

  /// Ejemplo de ruta montada sobre [baseUrl] (solo documentación / tests).
  Uri? resolveProvisional(String relativePath) {
    final base = _baseUrl;
    if (base == null) return null;
    return base.replace(path: '${base.path}$relativePath');
  }

  /// Referencia al contrato documentado para asistente.
  static String get assistantMessagePath => ApiEndpoints.assistantMessage;
}
