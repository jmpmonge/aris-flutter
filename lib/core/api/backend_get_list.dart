import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'api_result.dart';

const Duration _listGetTimeout = Duration(seconds: 45);

/// GET JSON que devuelve un **array de objetos** (p. ej. `/history`).
Future<ApiResult<List<Map<String, dynamic>>>> backendGetJsonList({
  required Uri? baseUri,
  required String path,
  required String debugLabel,
}) async {
  if (baseUri == null) {
    debugPrint('[$debugLabel] sin baseUri');
    return ApiResult.failure(
      ApiException('GET $path sin URL base configurada', code: 'no_backend'),
    );
  }

  final uri = baseUri.resolve(path);
  debugPrint('[$debugLabel] URL: $uri');

  try {
    final response = await http
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(_listGetTimeout);

    debugPrint('[$debugLabel] statusCode: ${response.statusCode}');

    final raw = response.body;
    debugPrint(
      '[$debugLabel] response body: ${raw.length > 4500 ? '${raw.substring(0, 4500)}… (${raw.length} chars)' : raw}',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return ApiResult.failure(
        ApiException('HTTP ${response.statusCode} en GET $path', code: 'http_error'),
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (e) {
      debugPrint('[$debugLabel] JSON inválido: $e');
      return ApiResult.failure(
        ApiException(
          'GET $path no devolvió JSON válido',
          code: 'bad_response',
          cause: e,
        ),
      );
    }

    if (decoded is! List) {
      return ApiResult.failure(
        ApiException('GET $path: se esperaba un array JSON', code: 'bad_response'),
      );
    }

    final out = <Map<String, dynamic>>[];
    for (var i = 0; i < decoded.length; i++) {
      final e = decoded[i];
      if (e is Map<String, dynamic>) {
        out.add(e);
      } else if (e is Map) {
        out.add(Map<String, dynamic>.from(e));
      }
    }

    return ApiResult.success(out);
  } on TimeoutException catch (e, st) {
    debugPrint('[$debugLabel] TimeoutException: $e\n$st');
    return ApiResult.failure(
      ApiException(
        'Tiempo de espera en GET $path',
        code: 'timeout',
        cause: e,
      ),
    );
  } on http.ClientException catch (e, st) {
    debugPrint('[$debugLabel] ClientException: $e\n$st');
    return ApiResult.failure(
      ApiException('Sin conexión al backend', code: 'no_connection', cause: e),
    );
  } catch (e, st) {
    debugPrint('[$debugLabel] error: $e\n$st');
    return ApiResult.failure(
      ApiException(
        'Fallo al obtener GET $path',
        code: 'unknown',
        cause: e,
      ),
    );
  }
}
