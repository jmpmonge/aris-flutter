import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'api_result.dart';

const Duration _tasksNotesMutationTimeout = Duration(seconds: 45);

/// POST con cuerpo JSON (p. ej. creación **`/tasks`** v0.47.33).
Future<ApiResult<Map<String, dynamic>?>> backendPostTasksNotes({
  required Uri? baseUri,
  required String path,
  Map<String, dynamic>? jsonBody,
  required String debugLabel,
}) =>
    _runTasksNotesVerb(
      baseUri: baseUri,
      method: _Verb.post,
      path: path,
      jsonBody: jsonBody ?? const {},
      debugLabel: debugLabel,
      expectJsonObject: true,
    );

/// PATCH con cuerpo JSON (p. ej. `TaskPatchBody` / `NotePatchBody` en backend).
Future<ApiResult<Map<String, dynamic>?>> backendPatchTasksNotes({
  required Uri? baseUri,
  required String path,
  Map<String, dynamic>? jsonBody,
  required String debugLabel,
}) =>
    _runTasksNotesVerb(
      baseUri: baseUri,
      method: _Verb.patch,
      path: path,
      jsonBody: jsonBody ?? const {},
      debugLabel: debugLabel,
      expectJsonObject: true,
    );

/// PATCH sin entidad esperada en JSON útil (`/tasks/{id}/complete`).
Future<ApiResult<Map<String, dynamic>?>> backendPatchTasksNotesVoidBody({
  required Uri? baseUri,
  required String path,
  required String debugLabel,
}) =>
    _runTasksNotesVerb(
      baseUri: baseUri,
      method: _Verb.patch,
      path: path,
      jsonBody: const <String, dynamic>{},
      debugLabel: debugLabel,
      expectJsonObject: true,
    );

/// DELETE recurso `/tasks/{id}` o `/notes/{id}`.
Future<ApiResult<Map<String, dynamic>?>> backendDeleteTasksNotes({
  required Uri? baseUri,
  required String path,
  required String debugLabel,
}) =>
    _runTasksNotesVerb(
      baseUri: baseUri,
      method: _Verb.delete_,
      path: path,
      jsonBody: null,
      debugLabel: debugLabel,
      expectJsonObject: true,
    );

enum _Verb { patch, delete_, post }

Future<ApiResult<Map<String, dynamic>?>> _runTasksNotesVerb({
  required Uri? baseUri,
  required _Verb method,
  required String path,
  Map<String, dynamic>? jsonBody,
  required String debugLabel,
  required bool expectJsonObject,
}) async {
  if (baseUri == null) {
    debugPrint('$debugLabel sin baseUrl');
    return ApiResult.failure(
      ApiException('Sin URL base del backend configurada.', code: 'no_backend'),
    );
  }

  final uri = baseUri.resolve(path.startsWith('/') ? path.substring(1) : path);
  debugPrint('$debugLabel URL: $uri');

  final headers = <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  String? patchBodyStr;
  if (method != _Verb.delete_) {
    patchBodyStr = jsonEncode(jsonBody ?? {});
    debugPrint('$debugLabel request body: $patchBodyStr');
  }

  try {
    http.Response response;
    switch (method) {
      case _Verb.patch:
        response = await http
            .patch(uri, headers: headers, body: patchBodyStr)
            .timeout(_tasksNotesMutationTimeout);
      case _Verb.delete_:
        response = await http.delete(uri, headers: headers).timeout(
              _tasksNotesMutationTimeout,
            );
      case _Verb.post:
        response = await http
            .post(uri, headers: headers, body: patchBodyStr)
            .timeout(_tasksNotesMutationTimeout);
    }

    debugPrint('$debugLabel statusCode: ${response.statusCode}');

    final raw = response.body;
    final preview = raw.length > 4200 ? '${raw.substring(0, 4200)}…' : raw;
    debugPrint('$debugLabel response body: $preview');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return ApiResult.failure(
        ApiException(
          'HTTP ${response.statusCode} en $uri',
          code: 'http_error',
        ),
      );
    }

    if (raw.isEmpty || raw.trim().isEmpty) {
      return ApiResult.success(null);
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (e, st) {
      debugPrint('$debugLabel JSON inválido: $e\n$st');
      return expectJsonObject
          ? ApiResult.failure(
              ApiException(
                'Respuesta no JSON válido',
                code: 'bad_response',
                cause: e,
              ),
            )
          : ApiResult.success(null);
    }

    if (decoded is Map) {
      return ApiResult.success(Map<String, dynamic>.from(decoded));
    }

    return expectJsonObject
        ? ApiResult.failure(
            ApiException('Respuesta inesperada (no objeto JSON)', code: 'bad_response'),
          )
        : ApiResult.success(null);
  } on TimeoutException catch (e, st) {
    debugPrint('$debugLabel TimeoutException: $e\n$st');
    return ApiResult.failure(
      ApiException('Tiempo de espera del servidor.', code: 'timeout', cause: e),
    );
  } on http.ClientException catch (e, st) {
    debugPrint('$debugLabel ClientException: $e\n$st');
    return ApiResult.failure(
      ApiException('Sin conexión al backend', code: 'no_connection', cause: e),
    );
  } catch (e, st) {
    debugPrint('$debugLabel error: $e\n$st');
    return ApiResult.failure(
      ApiException('Fallo de red', code: 'unknown', cause: e),
    );
  }
}
