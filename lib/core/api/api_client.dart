import 'package:flutter/foundation.dart';

import 'api_config.dart';
import 'api_endpoints.dart';
import 'api_exception.dart';
import 'api_result.dart';
import 'backend_get_list.dart';
import 'backend_tasks_notes_http.dart';
import 'health_check.dart';
import 'message_post.dart';

/// Cliente HTTP: health, GET listas (v0.41), **`POST /message`** (v0.40),
/// mutaciones **tareas/notas** (v0.42) y **eventos** (v0.44 PATCH/DELETE).
///
/// Los métodos **genéricos** `get/post/patch` sin ruta siguen como stubs locales.
final class ApiClient {
  ApiClient({Uri? baseUrl}) : _baseUrl = baseUrl;

  final Uri? _baseUrl;

  /// `true` cuando hay URL base (no implica que el servidor esté en marcha).
  bool get isConfigured => _baseUrl != null;

  Uri? get baseUrl => _baseUrl;

  /// Instancia de demostración sin host (`checkHealth` y CRUD → fallo estable).
  factory ApiClient.provisional() => ApiClient();

  /// Backend local según [ApiConfig] (uso previsto para health check v0.39).
  factory ApiClient.localBackend() => ApiClient(baseUrl: ApiConfig.baseUri);

  /// Comprueba `GET .../health`. No lanza por errores de red; devuelve
  /// [ApiResult.failure].
  ///
  /// Respuesta esperada: `{"status":"ok"}` con HTTP 200.
  Future<ApiResult<Map<String, dynamic>>> checkHealth() =>
      runBackendHealth(_baseUrl);

  /// POST [`ApiEndpoints.message`] con cuerpo **`{"text": "<mensaje>"}`** (sin otras claves).
  ///
  /// Logs temporales: ver `message_post.dart` (`package:http`).
  Future<ApiResult<Map<String, dynamic>>> sendMessage(String text) {
    debugPrint(
      '[ApiClient.sendMessage] delegando postAssistantMessage (baseUrl: $_baseUrl)',
    );
    return postAssistantMessage(_baseUrl, text);
  }

  Future<ApiResult<List<Map<String, dynamic>>>> getHistory() =>
      backendGetJsonList(
        baseUri: _baseUrl,
        path: ApiEndpoints.historyList,
        debugLabel: 'ApiClient.getHistory',
      );

  Future<ApiResult<List<Map<String, dynamic>>>> getTasks() =>
      backendGetJsonList(
        baseUri: _baseUrl,
        path: ApiEndpoints.tasksList,
        debugLabel: 'ApiClient.getTasks',
      );

  Future<ApiResult<List<Map<String, dynamic>>>> getNotes() =>
      backendGetJsonList(
        baseUri: _baseUrl,
        path: ApiEndpoints.notesList,
        debugLabel: 'ApiClient.getNotes',
      );

  Future<ApiResult<List<Map<String, dynamic>>>> getEvents() =>
      backendGetJsonList(
        baseUri: _baseUrl,
        path: ApiEndpoints.eventsList,
        debugLabel: 'ApiClient.getEvents',
      );

  /// PATCH [`ApiEndpoints.taskPath`] con **`{"completed": bool}`** (v0.47.31+).
  Future<ApiResult<Map<String, dynamic>?>> patchTaskCompletion(
    String taskId,
    bool completed,
  ) {
    const tag = '[ApiClient.patchTaskCompletion]';
    debugPrint('$tag delegando (baseUrl: $_baseUrl)');
    final id = taskId.trim();
    if (id.isEmpty) {
      return Future.value(
        ApiResult.failure(
          ApiException('Identificador de tarea vacío', code: 'validation'),
        ),
      );
    }
    return backendPatchTasksNotes(
      baseUri: _baseUrl,
      path: ApiEndpoints.taskPath(id),
      jsonBody: <String, dynamic>{'completed': completed},
      debugLabel: tag,
    );
  }

  /// Equivale a [patchTaskCompletion] con **`completed: true`**.
  Future<ApiResult<Map<String, dynamic>?>> completeTask(String taskId) =>
      patchTaskCompletion(taskId, true);

  /// Edición de título por REST — **no** soportada en backend minimal **v0.47.31**
  /// (`PATCH /tasks/{id}` sólo admite **`completed`** para el checkbox).
  Future<ApiResult<Map<String, dynamic>?>> updateTask(
    String taskId, {
    String? title,
    String? description,
  }) {
    const tag = '[ApiClient.updateTask]';
    debugPrint('$tag no disponible en backend v0.47.31 (sin PATCH de título)');
    final id = taskId.trim();
    if (id.isEmpty) {
      return Future.value(
        ApiResult.failure(
          ApiException('Identificador de tarea vacío', code: 'validation'),
        ),
      );
    }
    return Future.value(
      ApiResult.failure(
        ApiException(
          'Edición de título no disponible en esta versión del backend.',
          code: 'unsupported',
        ),
      ),
    );
  }

  /// DELETE **`/tasks/{id}`**.
  Future<ApiResult<Map<String, dynamic>?>> deleteTask(String taskId) {
    const tag = '[ApiClient.deleteTask]';
    debugPrint('$tag delegando (baseUrl: $_baseUrl)');
    final id = taskId.trim();
    if (id.isEmpty) {
      return Future.value(
        ApiResult.failure(
          ApiException('Identificador de tarea vacío', code: 'validation'),
        ),
      );
    }
    return backendDeleteTasksNotes(
      baseUri: _baseUrl,
      path: ApiEndpoints.taskPath(id),
      debugLabel: tag,
    );
  }

  /// PATCH **`/notes/{id}`** con **`NotePatchBody`**: campo **`content`** únicamente (FastAPI).
  Future<ApiResult<Map<String, dynamic>?>> updateNote(
    String noteId, {
    String? title,
    String? content,
  }) {
    const tag = '[ApiClient.updateNote]';
    debugPrint('$tag delegando (baseUrl: $_baseUrl)');
    final id = noteId.trim();
    if (id.isEmpty) {
      return Future.value(
        ApiResult.failure(
          ApiException('Identificador de nota vacío', code: 'validation'),
        ),
      );
    }
    final wire = _wireNotePatchContent(title: title, content: content);
    if (wire.isEmpty) {
      debugPrint('$tag content combinado vacío');
      return Future.value(
        ApiResult.failure(
          ApiException('El contenido de la nota no puede estar vacío.', code: 'validation'),
        ),
      );
    }
    return backendPatchTasksNotes(
      baseUri: _baseUrl,
      path: ApiEndpoints.notePath(id),
      jsonBody: <String, dynamic>{'content': wire},
      debugLabel: tag,
    );
  }

  /// DELETE **`/notes/{id}`**.
  Future<ApiResult<Map<String, dynamic>?>> deleteNote(String noteId) {
    const tag = '[ApiClient.deleteNote]';
    debugPrint('$tag delegando (baseUrl: $_baseUrl)');
    final id = noteId.trim();
    if (id.isEmpty) {
      return Future.value(
        ApiResult.failure(
          ApiException('Identificador de nota vacío', code: 'validation'),
        ),
      );
    }
    return backendDeleteTasksNotes(
      baseUri: _baseUrl,
      path: ApiEndpoints.notePath(id),
      debugLabel: tag,
    );
  }

  /// PATCH **`/events/{id}`** (v0.43 backend · v0.44 cliente). Omitir null;
  /// el JSON no debe ser `{}`.
  Future<ApiResult<Map<String, dynamic>?>> updateEvent(
    String eventId, {
    String? title,
    String? dateText,
    String? timeText,
    String? location,
    List<String>? participants,
    String? description,
    int? durationMinutes,
    double? confidence,
    bool? needsConfirmation,
    List<String>? missingFields,
    String? sourceText,
  }) {
    const tag = '[ApiClient.updateEvent]';
    debugPrint('$tag delegando (baseUrl: $_baseUrl)');
    final id = eventId.trim();
    if (id.isEmpty) {
      return Future.value(
        ApiResult.failure(
          ApiException('Identificador de evento vacío', code: 'validation'),
        ),
      );
    }

    final body = <String, dynamic>{};
    void putStr(String snake, String? v) {
      if (v == null) return;
      final s = v.trim();
      if (s.isEmpty) return;
      body[snake] = s;
    }

    putStr('title', title);
    putStr('date_text', dateText);
    putStr('time_text', timeText);
    putStr('location', location);
    putStr('description', description);
    putStr('source_text', sourceText);

    if (participants != null && participants.isNotEmpty) {
      body['participants'] = participants;
    }
    if (durationMinutes != null && durationMinutes > 0) {
      body['duration_minutes'] = durationMinutes;
    }
    if (confidence != null) {
      if (confidence >= 0 && confidence <= 1) {
        body['confidence'] = confidence;
      } else {
        debugPrint('$tag confidence fuera de [0,1] omitido: $confidence');
      }
    }
    if (needsConfirmation != null) {
      body['needs_confirmation'] = needsConfirmation;
    }
    if (missingFields != null && missingFields.isNotEmpty) {
      body['missing_fields'] = missingFields;
    }

    if (body.isEmpty) {
      debugPrint('$tag patch vacío (sin campos enviables)');
      return Future.value(
        ApiResult.failure(
          ApiException(
            'Debes incluir al menos un campo válido para el evento.',
            code: 'validation',
          ),
        ),
      );
    }

    return backendPatchTasksNotes(
      baseUri: _baseUrl,
      path: ApiEndpoints.eventPath(id),
      jsonBody: body,
      debugLabel: tag,
    );
  }

  /// DELETE **`/events/{id}`** (v0.43 backend · v0.44 cliente).
  Future<ApiResult<Map<String, dynamic>?>> deleteEvent(String eventId) {
    const tag = '[ApiClient.deleteEvent]';
    debugPrint('$tag delegando (baseUrl: $_baseUrl)');
    final id = eventId.trim();
    if (id.isEmpty) {
      return Future.value(
        ApiResult.failure(
          ApiException('Identificador de evento vacío', code: 'validation'),
        ),
      );
    }
    return backendDeleteTasksNotes(
      baseUri: _baseUrl,
      path: ApiEndpoints.eventPath(id),
      debugLabel: tag,
    );
  }

  /// GET genérico — **sin** red real hasta integrar otros endpoints.
  Future<ApiResult<Map<String, dynamic>>> get(
    String path, {
    Map<String, String>? query,
  }) async {
    return ApiResult.failure(
      ApiException(
        'GET no disponible para este recurso sin integración previa ($path)',
        code: 'no_backend',
      ),
    );
  }

  /// POST genérico — **sin** implementación de red hoy (salvo rutas futuras).
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
    final b = _baseUrl;
    if (b == null) return null;
    return b.replace(path: '${b.path}$relativePath');
  }

  /// Referencia al contrato documentado para asistente.
  static String get assistantMessagePath => ApiEndpoints.assistantMessage;
}

  final t = (title ?? '').trim();
  final c = (content ?? '').trim();
  if (t.isEmpty && c.isEmpty) return '';
  if (t.isEmpty) return c;
  if (c.isEmpty) return t;
  return '$t\n\n$c';
}

