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

  static const profileMenu = [
    ProfileMenuEntryModel(
      iconKey: 'mail_outline_rounded',
      title: 'Mail',
      subtitle: 'Bandeja simulada local',
    ),
    ProfileMenuEntryModel(
      iconKey: 'person_rounded',
      title: 'Cuenta',
      subtitle: 'Datos de perfil simulados',
    ),
    ProfileMenuEntryModel(
      iconKey: 'tune_rounded',
      title: 'Preferencias',
      subtitle: 'Notificaciones, idioma…',
    ),
    ProfileMenuEntryModel(
      iconKey: 'hub_outlined',
      title: 'Integraciones',
      subtitle: 'Próximamente · sin APIs',
    ),
    ProfileMenuEntryModel(
      iconKey: 'shield_outlined',
      title: 'Privacidad',
      subtitle: 'Políticas de ejemplo',
    ),
    ProfileMenuEntryModel(
      iconKey: 'help_outline_rounded',
      title: 'Ayuda',
      subtitle: 'Centro de ayuda mock',
    ),
  ];
}
