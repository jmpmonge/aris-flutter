import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../models/backend_event_mapper.dart';
import '../models/event_model.dart';
import '../models/local_action_model.dart';
import '../services/calendar_service.dart';
import '../services/local_action_service.dart';

abstract interface class CalendarRepository {
  ValueNotifier<int> get readRevision;

  /// Verdadero cuando el último GET `/events` fue correcto (lista puede vaciarse).
  bool get readsFromBackend;

  Future<bool> refreshFromBackend();

  List<EventModel> getTodayEvents([DateTime? day]);

  List<EventModel> getWeekEvents(DateTime dayInWeek);

  bool getMonthDayHasEvent(DateTime monthAnchor, int dayOfMonth);

  List<EventModel> getMonthEvents(DateTime monthAnchor, int dayOfMonth);

  List<EventModel> getHomeHighlightEvents([DateTime? day]);

  /// Eventos cuyo `date_text` no es fecha ISO: no aparecen en columna día corriente.
  List<EventModel> get textualOnlyDateBackendEvents;

  List<LocalActionModel> getLocalEvents();

  LocalActionModel createLocalEvent({
    required String title,
    String? description,
    String? dateText,
  });

  /// PATCH **`/events/{id}`**. Si [readsFromBackend] es false, devuelve `false`.
  Future<bool> updateEvent(
    String eventId, {
    String? title,
    String? dateText,
    String? timeText,
    String? location,
    List<String>? participants,
    String? description,
    int? durationMinutes,
    double? confidence,
    bool? needsConfirmation,
    List<String>? missingFields,
    String? sourceText,
  });

  /// DELETE **`/events/{id}`**.
  Future<bool> deleteEvent(String eventId);
}

final class HybridCalendarRepository implements CalendarRepository {
  HybridCalendarRepository(this._client);

  final ApiClient _client;

  @override
  final ValueNotifier<int> readRevision = ValueNotifier<int>(0);

  bool _readsOk = false;
  List<EventModel> _backendEvents = [];

  @override
  bool get readsFromBackend => _readsOk;

  void _applyEventsPayload(List<Map<String, dynamic>> rawList) {
    _backendEvents = BackendEventMapper.parseAll(
      rawList,
      fallbackDay: DateTime.now(),
    );
  }

  @override
  Future<bool> refreshFromBackend() async {
    final res = await _client.getEvents();
    if (!res.isSuccess || res.data == null) {
      _readsOk = false;
      _backendEvents = [];
      readRevision.value++;
      return false;
    }
    _readsOk = true;
    _applyEventsPayload(res.data!);
    readRevision.value++;
    return true;
  }

  Future<void> _reloadCalendarAfterMutation() async {
    if (!_readsOk) return;
    final res = await _client.getEvents();
    if (!res.isSuccess || res.data == null) {
      debugPrint(
        '[HybridCalendarRepository] refresco tras mutación sin éxito; se conserva cache.',
      );
      return;
    }
    _readsOk = true;
    _applyEventsPayload(res.data!);
    readRevision.value++;
  }

  static bool _sameCalendarDay(DateTime a, DateTime b) {
    final al = a.toLocal();
    final bl = b.toLocal();
    return al.year == bl.year &&
        al.month == bl.month &&
        al.day == bl.day;
  }

  List<EventModel> _civilCalendarDay(DateTime day) {
    if (!_readsOk || _backendEvents.isEmpty) return [];
    final d =
        DateTime(day.year, day.month, day.day).toUtc().toLocal();
    final out =
        _backendEvents
            .where(
              (e) =>
                  e.hasCivilCalendarDate &&
                  _sameCalendarDay(e.start, d),
            )
            .toList();
    out.sort((a, b) => a.start.compareTo(b.start));
    return out;
  }

  List<EventModel> _textualOnlyDateBackendSorted() {
    if (!_readsOk) return [];
    final out =
        _backendEvents.where((e) => !e.hasCivilCalendarDate).toList();
    out.sort((a, b) => a.start.compareTo(b.start));
    return out;
  }

  @override
  List<EventModel> get textualOnlyDateBackendEvents =>
      List.unmodifiable(_textualOnlyDateBackendSorted());

  @override
  List<EventModel> getTodayEvents([DateTime? day]) {
    final d = day ?? DateTime.now();
    final civil = _civilCalendarDay(d);
    final textual = _textualOnlyDateBackendSorted();
    if (!_readsOk) return CalendarService.getTodayEvents(day);
    final merged = [...civil, ...textual];
    if (merged.isEmpty) return CalendarService.getTodayEvents(day);
    return merged;
  }

  @override
  List<EventModel> getWeekEvents(DateTime dayInWeek) {
    final anchored =
        DateTime(dayInWeek.year, dayInWeek.month, dayInWeek.day);
    final fromNet = _civilCalendarDay(anchored);
    if (!_readsOk) return CalendarService.getWeekEvents(dayInWeek);
    if (fromNet.isEmpty) return CalendarService.getWeekEvents(dayInWeek);
    return fromNet;
  }

  @override
  bool getMonthDayHasEvent(DateTime monthAnchor, int dayOfMonth) {
    final candidate =
        DateTime(monthAnchor.year, monthAnchor.month, dayOfMonth);
    if (!_readsOk) {
      return CalendarService.getMonthDayHasEvent(monthAnchor, dayOfMonth);
    }
    final fromNet =
        _backendEvents.any(
          (e) =>
              e.hasCivilCalendarDate &&
              _sameCalendarDay(e.start, candidate),
        );
    if (fromNet) return true;
    return CalendarService.getMonthDayHasEvent(monthAnchor, dayOfMonth);
  }

  @override
  List<EventModel> getMonthEvents(DateTime monthAnchor, int dayOfMonth) {
    final fromNet =
        _civilCalendarDay(
          DateTime(monthAnchor.year, monthAnchor.month, dayOfMonth),
        );
    if (!_readsOk) {
      return CalendarService.getMonthEvents(monthAnchor, dayOfMonth);
    }
    if (fromNet.isEmpty) {
      return CalendarService.getMonthEvents(monthAnchor, dayOfMonth);
    }
    return fromNet;
  }

  @override
  List<EventModel> getHomeHighlightEvents([DateTime? day]) {
    final d = day ?? DateTime.now();
    if (!_readsOk) {
      return CalendarService.getHomeHighlightEvents(day);
    }
    final civil = _civilCalendarDay(d);
    final textual = _textualOnlyDateBackendSorted();
    final merged = <EventModel>[];
    merged.addAll(civil.take(3));
    final need = (3 - merged.length).clamp(0, 99);
    if (need > 0) {
      merged.addAll(textual.take(need));
    }
    if (merged.isEmpty) {
      return CalendarService.getHomeHighlightEvents(day);
    }
    return merged;
  }

  @override
  List<LocalActionModel> getLocalEvents() =>
      LocalActionService.getActionsByType(LocalActionType.event);

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

  @override
  Future<bool> updateEvent(
    String eventId, {
    String? title,
    String? dateText,
    String? timeText,
    String? location,
    List<String>? participants,
    String? description,
    int? durationMinutes,
    double? confidence,
    bool? needsConfirmation,
    List<String>? missingFields,
    String? sourceText,
  }) async {
    if (!_readsOk) return false;
    final res = await _client.updateEvent(
      eventId,
      title: title,
      dateText: dateText,
      timeText: timeText,
      location: location,
      participants: participants,
      description: description,
      durationMinutes: durationMinutes,
      confidence: confidence,
      needsConfirmation: needsConfirmation,
      missingFields: missingFields,
      sourceText: sourceText,
    );
    if (!res.isSuccess) return false;
    await _reloadCalendarAfterMutation();
    return true;
  }

  @override
  Future<bool> deleteEvent(String eventId) async {
    if (!_readsOk) return false;
    final res = await _client.deleteEvent(eventId);
    if (!res.isSuccess) return false;
    await _reloadCalendarAfterMutation();
    return true;
  }
}
