import 'backend_date_hints.dart';
import 'event_model.dart';

/// Mapper desde filas `/events` (`title`, `date_text`, `time_text`,
/// `description`, `location`, `participants`, `created_at`, …).
abstract final class BackendEventMapper {
  static EventModel? tryParse(
    Map<String, dynamic> m, {
    required DateTime fallbackDay,
  }) {
    try {
      final idRaw = _str(m['id']);
      final syntheticBackendId = idRaw.isEmpty;
      final id =
          syntheticBackendId
              ? 'ev_${fallbackDay.microsecondsSinceEpoch}_${identityHashCode(m)}'
              : idRaw;

      final titleRaw = _str(m['title']);
      final title =
          titleRaw.trim().isEmpty ? 'Evento' : titleRaw.trim();

      final resolved =
          BackendDateTimeHints.resolveEventInstant(
            data: m,
            fallbackCalendarDay: fallbackDay,
          );
      final dateText = _str(m['date_text']);
      final timeText = _str(m['time_text']);
      final desc = _str(m['description']);
      final loc = _str(m['location']);
      final participants = _participantsList(m['participants']);

      final detailBits = <String>[
        if (desc.isNotEmpty) desc,
        if (loc.isNotEmpty) loc,
        if (participants.isNotEmpty) participants.join(', '),
      ];
      final detailJoined = detailBits.join(' · ');
      final detail =
          detailJoined.length > 360
              ? '${detailJoined.substring(0, 357)}…'
              : detailJoined;

      final durationMinutes = _intOrNull(m['duration_minutes']);
      final confidence = _doubleOrNull(m['confidence']);
      final bool? needsConfirmation =
          m['needs_confirmation'] is bool ? m['needs_confirmation'] as bool : null;
      final missingFields = _stringListNonEmpty(m['missing_fields']);
      final sourceTxt = _str(m['source_text']);
      final sourceText = sourceTxt.isEmpty ? null : sourceTxt;

      final createdAt = DateTime.tryParse(_str(m['created_at']));
      final updatedAt = DateTime.tryParse(_str(m['updated_at']));

      return EventModel(
        id: id,
        syntheticBackendId: syntheticBackendId,
        start: resolved.start,
        hasCivilCalendarDate: resolved.hasCivilCalendarDate,
        title: title,
        detail: detail,
        dateText: dateText,
        timeText: timeText,
        location: loc,
        description: desc,
        participants: participants,
        durationMinutes: durationMinutes,
        confidence: confidence,
        needsConfirmation: needsConfirmation,
        missingFields: missingFields,
        sourceText: sourceText,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } on Object {
      return null;
    }
  }

  static String _str(Object? v) => v?.toString().trim() ?? '';

  static int? _intOrNull(Object? v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString().trim());
  }

  static double? _doubleOrNull(Object? v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString().trim());
  }

  static List<String> _participantsList(Object? raw) {
    if (raw is! List) return [];
    return raw
        .map((p) => p?.toString().trim())
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toList();
  }

  static List<String> _stringListNonEmpty(Object? raw) {
    if (raw is! List) return [];
    final out =
        raw
            .map((x) => x?.toString().trim())
            .whereType<String>()
            .where((s) => s.isNotEmpty)
            .toList();
    return out;
  }

  static List<EventModel> parseAll(
    List<Map<String, dynamic>> raw, {
    required DateTime fallbackDay,
  }) {
    final evs = <EventModel>[];
    for (final row in raw) {
      final e = BackendEventMapper.tryParse(row, fallbackDay: fallbackDay);
      if (e != null) evs.add(e);
    }
    evs.sort((a, b) => a.start.compareTo(b.start));
    return evs;
  }
}
