import '../mock/mock_events.dart';
import '../models/event_model.dart';

/// Servicio mock de agenda. Sin calendario del sistema ni API.
abstract final class CalendarService {
  static List<EventModel> getTodayEvents([DateTime? day]) {
    final d = day ?? DateTime.now();
    return MockEvents.daySchedule(DateTime(d.year, d.month, d.day));
  }

  /// Lista de eventos para un día de la semana concreto (columna semanal).
  static List<EventModel> getWeekEvents(DateTime dayInWeek) {
    return MockEvents.forWeekday(
      DateTime(dayInWeek.year, dayInWeek.month, dayInWeek.day),
    );
  }

  static bool getMonthDayHasEvent(DateTime monthAnchor, int dayOfMonth) {
    return MockEvents.monthDayHasMarker(dayOfMonth);
  }

  static List<EventModel> getMonthEvents(DateTime monthAnchor, int dayOfMonth) {
    return MockEvents.forMonthDay(monthAnchor, dayOfMonth);
  }

  /// Copia para bloque HOY del Home (textos distintos al día genérico).
  static List<EventModel> getHomeHighlightEvents([DateTime? day]) {
    final d = day ?? DateTime.now();
    return MockEvents.homeTodayHighlights(DateTime(d.year, d.month, d.day));
  }
}
