import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_endpoints.dart';
import 'api_exception.dart';
import 'api_result.dart';

/// Timeout para respuesta del servidor (GPT / motor simbólico en backend).
const Duration _assistantPostTimeout = Duration(seconds: 90);

/// POST [`ApiEndpoints.message`] con **`{"text":…}`**.
///
/// Implementación con `package:http`: válida en **Flutter Web** y móvil sin `dart:io`.
Future<ApiResult<Map<String, dynamic>>> postAssistantMessage(
  Uri? baseUrl,
  String text,
) async {
  const logTag = '[ApiClient.sendMessage]';

  if (baseUrl == null) {
    debugPrint('$logTag sin baseUrl');
    return ApiResult.failure(
      ApiException(
        'POST /message sin URL base configurada',
        code: 'no_backend',
      ),
    );
  }
  final merged = text.trim();
  if (merged.isEmpty) {
    debugPrint('$logTag mensaje vacío');
    return ApiResult.failure(
      ApiException('El mensaje no puede estar vacío', code: 'empty_message'),
    );
  }

  final uri = baseUrl.resolve(ApiEndpoints.message);
  final bodyJson = jsonEncode(<String, String>{'text': merged});

  debugPrint('$logTag URL: $uri');
  debugPrint('$logTag request body: $bodyJson');

  try {
    final response = await http
        .post(
          uri,
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: bodyJson,
        )
        .timeout(_assistantPostTimeout);

    debugPrint('$logTag statusCode: ${response.statusCode}');

    final raw = response.body;
    debugPrint('$logTag response body: $raw');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return ApiResult.failure(
        ApiException(
          'HTTP ${response.statusCode} en ${ApiEndpoints.message}',
          code: 'http_error',
        ),
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (e) {
      debugPrint('$logTag JSON inválido: $e');
      return ApiResult.failure(
        ApiException(
          'Respuesta ${ApiEndpoints.message} no es JSON válido',
          code: 'bad_response',
          cause: e,
        ),
      );
    }

    if (decoded is! Map) {
      return ApiResult.failure(
        ApiException(
          'Respuesta ${ApiEndpoints.message} inesperada',
          code: 'bad_response',
        ),
      );
    }
    return ApiResult.success(Map<String, dynamic>.from(decoded));
  } on TimeoutException catch (e, st) {
    debugPrint('$logTag error TimeoutException: $e\n$st');
    return ApiResult.failure(
      ApiException(
        'Tiempo de espera al enviar mensaje',
        code: 'timeout',
        cause: e,
      ),
    );
  } on http.ClientException catch (e, st) {
    debugPrint('$logTag error ClientException: $e\n$st');
    return ApiResult.failure(
      ApiException(
        'Sin conexión al backend',
        code: 'no_connection',
        cause: e,
      ),
    );
  } catch (e, st) {
    debugPrint('$logTag error: $e\n$st');
    return ApiResult.failure(
      ApiException(
        'Fallo al enviar ${ApiEndpoints.message}',
        code: 'unknown',
        cause: e,
      ),
    );
  }
}
