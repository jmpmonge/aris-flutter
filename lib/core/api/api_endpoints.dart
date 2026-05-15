/// Rutas **provisionales** del backend futuro de Aris.
///
/// **No** representan un servidor existente. Cualquier versión definitiva
/// puede cambiar prefijo (`/v1`), nombres o cuerpos. Usar solo como
/// convención de documentación y alineación con [docs/api_contract_v0_37.md].
abstract final class ApiEndpoints {
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
