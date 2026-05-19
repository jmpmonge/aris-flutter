import '../mock/mock_user.dart';
import '../models/user_model.dart';

abstract final class UserService {
  static UserModel getCurrentUser() => MockUser.current;

  static List<ProfileMenuEntryModel> getProfileMenuEntries() =>
      MockUser.profileMenu;

  static String getHomeSummaryLine() => MockUser.homeSummary;

  static String getHomeSuggestionLine() => MockUser.homeSuggestion;

  static String getGreetingForNow() {
    final h = DateTime.now().hour;
    final name = getCurrentUser().displayName;
    if (h < 12) return 'Buenos días, $name';
    if (h < 20) return 'Buenas tardes, $name';
    return 'Buenas noches, $name';
  }

  /// Saludo principal del Home diario: «Hola, José».
  static String getHomeGreetingShort() => 'Hola, ${getCurrentUser().displayName}';

  /// Fecha orientadora: «Hoy · Martes, 19 de mayo» (es-ES, día civil local).
  static String getHomeDateLine([DateTime? reference]) {
    final now = reference ?? DateTime.now();
    const weekdays = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo',
    ];
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    String cap(String s) =>
        s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

    final weekday = cap(weekdays[now.weekday - 1]);
    final month = months[now.month - 1];
    final dayMonth = '$weekday, ${now.day} de $month';

    final today = DateTime(now.year, now.month, now.day);
    final refDay = DateTime(now.year, now.month, now.day);
    if (today == refDay) {
      return 'Hoy · $dayMonth';
    }
    return dayMonth;
  }

  /// Fecha fija superior Home (v0.48.34): «Martes, 19 de mayo de 2026» — sin «Hoy».
  static String getHomeFixedDateLine([DateTime? reference]) {
    final now = reference ?? DateTime.now();
    const weekdays = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo',
    ];
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    String cap(String s) =>
        s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

    final weekday = cap(weekdays[now.weekday - 1]);
    final month = months[now.month - 1];
    return '$weekday, ${now.day} de $month de ${now.year}';
  }

  /// Fecha compacta sobre agenda (v0.48.32): «19 de mayo de 2026» — sin «Hoy».
  static String getHomeCompactDateLine([DateTime? reference]) {
    final now = reference ?? DateTime.now();
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${now.day} de ${months[now.month - 1]} de ${now.year}';
  }
}
