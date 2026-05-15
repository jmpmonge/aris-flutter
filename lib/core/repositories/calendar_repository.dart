import '../models/event_model.dart';
import '../models/local_action_model.dart';
import '../services/calendar_service.dart';
import '../services/local_action_service.dart';

/// Contrato de agenda / eventos (mock + locales). Implementación: [LocalCalendarRepository].
abstract interface class CalendarRepository {
  List<EventModel> getTodayEvents([DateTime? day]);

  List<EventModel> getWeekEvents(DateTime dayInWeek);

  bool getMonthDayHasEvent(DateTime monthAnchor, int dayOfMonth);

  List<EventModel> getMonthEvents(DateTime monthAnchor, int dayOfMonth);

  List<EventModel> getHomeHighlightEvents([DateTime? day]);

  List<LocalActionModel> getLocalEvents();

  LocalActionModel createLocalEvent({
    required String title,
    String? description,
    String? dateText,
  });
}

final class LocalCalendarRepository implements CalendarRepository {
  @override
  List<EventModel> getTodayEvents([DateTime? day]) =>
      CalendarService.getTodayEvents(day);

  @override
  List<EventModel> getWeekEvents(DateTime dayInWeek) =>
      CalendarService.getWeekEvents(dayInWeek);

  @override
  bool getMonthDayHasEvent(DateTime monthAnchor, int dayOfMonth) =>
      CalendarService.getMonthDayHasEvent(monthAnchor, dayOfMonth);

  @override
  List<EventModel> getMonthEvents(DateTime monthAnchor, int dayOfMonth) =>
      CalendarService.getMonthEvents(monthAnchor, dayOfMonth);

  @override
  List<EventModel> getHomeHighlightEvents([DateTime? day]) =>
      CalendarService.getHomeHighlightEvents(day);

  @override
  List<LocalActionModel> getLocalEvents() {
    return LocalActionService.getActionsByType(LocalActionType.event);
  }

  @override
  LocalActionModel createLocalEvent({
    required String title,
    String? description,
    String? dateText,
  }) {
    return LocalActionService.createEvent(
      title: title,
      description: description,
      dateText: dateText,
    );
  }
}
