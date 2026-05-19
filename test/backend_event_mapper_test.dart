import 'package:flutter_test/flutter_test.dart';

import 'package:aris_flutter_v0_22/core/models/backend_event_mapper.dart';
import 'package:aris_flutter_v0_22/core/models/event_model.dart';

void main() {
  test('BackendEventMapper: date_text textual «lunes» conserva fecha y marca sin civil',
      () {
    final fallback = DateTime(2026, 5, 17, 12, 0);
    final rows = BackendEventMapper.parseAll(
      [
        <String, dynamic>{
          'id': '1',
          'title': 'cita',
          'date_text': 'lunes',
          'time_text': '17:00',
        },
      ],
      fallbackDay: fallback,
    );

    expect(rows.length, 1);
    final e = rows.single;
    expect(e, isA<EventModel>());
    expect(e.dateText, 'lunes');
    expect(e.timeText, '17:00');
    expect(e.visibleDateLabel, 'lunes');
    expect(e.hasCivilCalendarDate, isFalse);
    expect(e.timeHm, '17:00');
    expect(calendarSameLocalDay(e.start, fallback), isFalse,
        reason:
            'el día civil del modelo no debe ser el fallback si date_text es textual');
    expect(e.start.hour, 17);
    expect(e.start.minute, 0);
  });

  test('BackendEventMapper: date_iso con date_text texto ancla día civil', () {
    final fallback = DateTime(2026, 5, 17, 12, 0);
    final rows = BackendEventMapper.parseAll(
      [
        <String, dynamic>{
          'id': '1',
          'title': 'cita',
          'date_text': 'lunes',
          'date_iso': '2026-05-18',
          'time_text': '20:00',
        },
      ],
      fallbackDay: fallback,
    );

    expect(rows.length, 1);
    final e = rows.single;
    expect(e.dateText, 'lunes');
    expect(e.dateIso, '2026-05-18');
    expect(e.hasCivilCalendarDate, isTrue);
    expect(
      calendarSameLocalDay(e.start, DateTime(2026, 5, 18)),
      isTrue,
    );
    expect(e.timeHm, '20:00');
  });
}

/// Copia estable de la heurística UI (solo test): mismos día/mes/año locales.
bool calendarSameLocalDay(DateTime a, DateTime b) {
  final al = DateTime(a.year, a.month, a.day);
  final rl = DateTime(b.year, b.month, b.day);
  return al.year == rl.year && al.month == rl.month && al.day == rl.day;
}
