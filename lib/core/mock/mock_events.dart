import '../models/event_model.dart';

/// Eventos de demostración para [CalendarService].
abstract final class MockEvents {
  static const String _cafeDescription =
      'Llevar documentación del contrato. '
      'Confirmar asistentes con Laura antes de las 8:45.';

  /// Café con Laura — caso de prueba completo para tarjeta expandida.
  static EventModel demoCafeLaura(
    DateTime day, {
    required String id,
    int hour = 9,
    int minute = 0,
  }) {
    final d = DateTime(day.year, day.month, day.day);
    return EventModel(
      id: id,
      start: DateTime(d.year, d.month, d.day, hour, minute),
      end: DateTime(d.year, d.month, d.day, hour + 1, minute),
      title: 'Café con Laura',
      location: 'Café Central',
      description: _cafeDescription,
      reminderMinutesBefore: 15,
      participants: const ['Laura'],
      weekIconKey: 'coffee',
    );
  }

  /// Agenda Día — tres eventos con detalle completo (v0.49.94+).
  static List<EventModel> daySchedule(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return [
      demoCafeLaura(d, id: 'mock_evt_cafe'),
      EventModel(
        id: 'mock_evt_lunch',
        start: DateTime(d.year, d.month, d.day, 12, 30),
        end: DateTime(d.year, d.month, d.day, 13, 0),
        title: 'Almuerzo equipo',
        location: 'Restaurante Norte',
        description: 'Mesa reservada · equipo producto',
        weekIconKey: 'meal',
      ),
      EventModel(
        id: 'mock_evt_gym',
        start: DateTime(d.year, d.month, d.day, 18, 0),
        end: DateTime(d.year, d.month, d.day, 19, 0),
        title: 'Gimnasio',
        location: 'Centro deportivo',
        description: 'Rutina piernas · estiramientos al final',
        weekIconKey: 'gym',
      ),
    ];
  }

  /// IDs de eventos demo de [daySchedule] — siempre visibles en vista Día.
  static const demoDayEventIds = {
    'mock_evt_cafe',
    'mock_evt_lunch',
    'mock_evt_gym',
  };

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
            weekIconKey: 'sync',
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
            weekIconKey: 'send',
          ),
        ];
      case DateTime.saturday:
        return [
          EventModel(
            id: 'mock_week_market',
            start: DateTime(d.year, d.month, d.day, 10, 30),
            title: 'Mercado',
            detail: 'Lista corta (mock)',
            weekIconKey: 'shopping',
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

  /// Eventos mostrados en el resumen «HOY» del Home — café enriquecido como Día.
  static List<EventModel> homeTodayHighlights(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final events = [
      demoCafeLaura(d, id: 'mock_home_evt_cafe', hour: 10, minute: 0),
      EventModel(
        id: 'mock_home_evt_med',
        start: DateTime(d.year, d.month, d.day, 15, 30),
        end: DateTime(d.year, d.month, d.day, 16, 30),
        title: 'Revisión médica anual',
        location: 'Centro Norte',
        description: 'Llevar analíticas y tarjeta sanitaria',
        reminderMinutesBefore: 30,
        weekIconKey: 'salud',
      ),
      EventModel(
        id: 'mock_home_evt_pkg',
        start: DateTime(d.year, d.month, d.day, 18, 0),
        title: 'Recoger paquete en locker',
        location: 'Estación Atocha · locker 12',
        weekIconKey: 'send',
      ),
    ];
    events.sort((a, b) => a.start.compareTo(b.start));
    return events;
  }
}
