/// Evento simulado con hora de inicio (solo presentación).
typedef CalendarEventMock = ({
  int hour,
  int minute,
  String title,
  String detail,
});

/// Datos mock para [CalendarScreen] (día, semana, mes).
abstract final class CalendarMockContent {
  /// Lista compacta legada (misma información que día).
  static const events = [
    ('09:00', 'Café con Laura', 'Café Central (mock)'),
    ('12:30', 'Almuerzo equipo', 'Online'),
    ('18:00', 'Gimnasio', 'Plan suave'),
  ];

  static const dayEvents = <CalendarEventMock>[
    (
      hour: 9,
      minute: 0,
      title: 'Café con Laura',
      detail: 'Café Central (mock)',
    ),
    (hour: 12, minute: 30, title: 'Almuerzo equipo', detail: 'Online'),
    (hour: 18, minute: 0, title: 'Gimnasio', detail: 'Plan suave'),
  ];

  static const _weekExtras = <CalendarEventMock>[
    (hour: 11, minute: 0, title: 'Sync rápido', detail: '15 min · mock'),
    (hour: 16, minute: 0, title: 'Enviar resumen', detail: 'Borrador simulado'),
  ];

  /// Formato "HH:MM" para filas tipo agenda.
  static String formatTime(CalendarEventMock e) {
    final h = e.hour.toString().padLeft(2, '0');
    final m = e.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Distribución mock por día de la semana (1 = lunes … 7 = domingo).
  static List<CalendarEventMock> eventsForWeekday(int weekday) {
    return switch (weekday) {
      DateTime.monday => [_weekExtras[0]],
      DateTime.tuesday => [dayEvents[0]],
      DateTime.wednesday => [dayEvents[1]],
      DateTime.thursday => const <CalendarEventMock>[],
      DateTime.friday => [dayEvents[2], _weekExtras[1]],
      DateTime.saturday => const <CalendarEventMock>[
        (hour: 10, minute: 30, title: 'Mercado', detail: 'Lista corta (mock)'),
      ],
      _ => const <CalendarEventMock>[],
    };
  }

  /// Días del mes (1-based) que muestran punto de evento en la cuadrícula.
  static bool monthDayHasMarker(int dayOfMonth) {
    return {3, 9, 12, 15, 18, 22}.contains(dayOfMonth);
  }

  /// Eventos mock para un día concreto del mes ancla.
  static List<CalendarEventMock> eventsForMonthDay(
    DateTime monthAnchor,
    int dayOfMonth,
  ) {
    final d = DateTime(monthAnchor.year, monthAnchor.month, dayOfMonth);
    if (!monthDayHasMarker(dayOfMonth)) return [];
    if (dayOfMonth == 15) return dayEvents;
    if (dayOfMonth == 9 || dayOfMonth == 22) {
      return [dayEvents[0], dayEvents[1]];
    }
    return [dayEvents[d.day % dayEvents.length]];
  }
}
