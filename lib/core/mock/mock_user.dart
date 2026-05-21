import '../models/user_model.dart';

abstract final class MockUser {
  static const current = UserModel(
    id: 'mock_user_jose',
    displayName: 'José',
    emailSimulated: 'jose@ejemplo.aris (simulado)',
    avatarInitial: 'J',
  );

  static const homeSummary =
      'Tienes 12 tareas pendientes y 2 eventos esta tarde. Respira: es un resumen simulado para diseño.';

  static const homeSuggestion =
      'Revisa tus tareas pendientes antes del fin de semana.';

  /// Menú Perfil (v0.49.25): sin Cuenta ni Integraciones duplicadas.
  static const profileMenu = [
    ProfileMenuEntryModel(
      iconKey: 'hub_outlined',
      title: 'Conexiones',
      subtitle: 'Mail, calendario y servicios',
    ),
    ProfileMenuEntryModel(
      iconKey: 'tune_rounded',
      title: 'Preferencias',
      subtitle: 'Idioma, apariencia y notificaciones',
    ),
    ProfileMenuEntryModel(
      iconKey: 'shield_outlined',
      title: 'Privacidad',
      subtitle: 'Datos, permisos y seguridad',
    ),
    ProfileMenuEntryModel(
      iconKey: 'help_outline_rounded',
      title: 'Ayuda',
      subtitle: 'Soporte y comentarios',
    ),
  ];
}
