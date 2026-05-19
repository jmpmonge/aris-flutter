/// Rutas **provisionales** del backend futuro de Aris.
///
/// **No** representan un servidor existente. Cualquier versión definitiva
/// puede cambiar prefijo (`/v1`), nombres o cuerpos. Usar solo como
/// convención de documentación y alineación con [docs/api_contract_v0_37.md].
abstract final class ApiEndpoints {
  /// Contrato real del backend FastAPI actual (sin prefijo versionado).
  static const String health = '/health';

  /// POST cuerpo de usuario para el motor en servidor ([UserMessage]: campo `text`).
  static const String message = '/message';

  /// GET listas de dominio (stores JSON en backend).
  static const String historyList = '/history';
  static const String tasksList = '/tasks';
  static const String notesList = '/notes';
  static const String eventsList = '/events';

  /// Mutaciones sobre tareas y notas (FastAPI sin prefijo).
  static String taskPath(String taskId) => '/tasks/${Uri.encodeComponent(taskId)}';
  static String taskCompletePath(String taskId) =>
      '${taskPath(taskId)}/complete';
  static String notePath(String noteId) =>
      '/notes/${Uri.encodeComponent(noteId)}';
  static String eventPath(String eventId) =>
      '/events/${Uri.encodeComponent(eventId)}';

  static const String provisionalPrefix = '/v1';

  static const String assistantMessage = '$provisionalPrefix/assistant/message';

  static const String tasks = '$provisionalPrefix/tasks';
  static const String notes = '$provisionalPrefix/notes';
  static const String events = '$provisionalPrefix/events';

  static const String mailSummary = '$provisionalPrefix/mail/summary';
  static const String mailDraft = '$provisionalPrefix/mail/draft';

  static const String userProfile = '$provisionalPrefix/user/profile';

  /// Preferencia de tema almacenada en servidor (futuro). Hoy: solo local.
  static const String settingsTheme = '$provisionalPrefix/settings/theme';
}
