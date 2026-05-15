import '../models/event_model.dart';

/// Eventos de demostración para [CalendarService].
abstract final class MockEvents {
  static List<EventModel> daySchedule(DateTime day) {
    return [
      EventModel(
        id: 'mock_evt_cafe',
        start: DateTime(day.year, day.month, day.day, 9, 0),
        title: 'Café con Laura',
        detail: 'Café Central (mock)',
      ),
      EventModel(
        id: 'mock_evt_lunch',
        start: DateTime(day.year, day.month, day.day, 12, 30),
        title: 'Almuerzo equipo',
        detail: 'Online',
      ),
      EventModel(
        id: 'mock_evt_gym',
        start: DateTime(day.year, day.month, day.day, 18, 0),
        title: 'Gimnasio',
        detail: 'Plan suave',
      ),
    ];
  }

  static List<EventModel> forWeekday(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final base = daySchedule(d);
    switch (day.weekday) {
      case DateTime.monday:
        return [
          EventModel(
            id: 'mock_week_sync',
            start: DateTime(d.year, d.month, d.day, 11, 0),
            title: 'Sync rápido',
            detail: '15 min · mock',
          ),
        ];
      case DateTime.tuesday:
        return [base[0]];
      case DateTime.wednesday:
        return [base[1]];
      case DateTime.thursday:
        return [];
      case DateTime.friday:
        return [
          base[2],
          EventModel(
            id: 'mock_week_res',
            start: DateTime(d.year, d.month, d.day, 16, 0),
            title: 'Enviar resumen',
            detail: 'Borrador simulado',
          ),
        ];
      case DateTime.saturday:
        return [
          EventModel(
            id: 'mock_week_market',
            start: DateTime(d.year, d.month, d.day, 10, 30),
            title: 'Mercado',
            detail: 'Lista corta (mock)',
          ),
        ];
      default:
        return [];
    }
  }

  static const monthMarkerDays = {3, 9, 12, 15, 18, 22};

  static bool monthDayHasMarker(int dayOfMonth) =>
      monthMarkerDays.contains(dayOfMonth);

  static List<EventModel> forMonthDay(DateTime monthAnchor, int dayOfMonth) {
    final d = DateTime(monthAnchor.year, monthAnchor.month, dayOfMonth);
    if (!monthDayHasMarker(dayOfMonth)) return [];
    final base = daySchedule(d);
    if (dayOfMonth == 15) return base;
    if (dayOfMonth == 9 || dayOfMonth == 22) {
      return [base[0], base[1]];
    }
    return [base[dayOfMonth % base.length]];
  }

  /// Eventos mostrados en el resumen «HOY» del Home (copia enriquecida).
  static List<EventModel> homeTodayHighlights(DateTime day) {
    return [
      EventModel(
        id: 'mock_home_evt_med',
        start: DateTime(day.year, day.month, day.day, 15, 30),
        title: 'Revisión médica anual',
        detail: 'Centro Norte, mock',
      ),
      EventModel(
        id: 'mock_home_evt_pkg',
        start: DateTime(day.year, day.month, day.day, 18, 0),
        title: 'Recoger paquete en locker',
        detail: '',
      ),
    ];
  }
}
