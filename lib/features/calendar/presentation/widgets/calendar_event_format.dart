import '../../../../core/models/event_model.dart';

/// Formato de fechas/horas de eventos (v0.49.45).
abstract final class CalendarEventFormat {
  CalendarEventFormat._();

  static const _weekdays = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
  ];
  static const _months = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];
  static const _monthsShort = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  static String dayHeader(DateTime day) {
    final wd = _weekdays[day.weekday - DateTime.monday];
    return '$wd, ${day.day} de ${_months[day.month - 1]} de ${day.year}';
  }

  static String monthDayHeader(DateTime month, int day) {
    final d = DateTime(month.year, month.month, day);
    final wd = _weekdays[d.weekday - DateTime.monday];
    return '$wd, $day de ${_months[d.month - 1]}';
  }

  static String shortDate(EventModel event) {
    if (event.dateText.trim().isNotEmpty) return event.dateText.trim();
    final d = event.start;
    final wd = _weekdays[d.weekday - DateTime.monday].substring(0, 3);
    return '$wd, ${d.day} ${_monthsShort[d.month - 1]} ${d.year}';
  }

  /// Fecha corta + hora para tarjeta expandida Día (v0.49.62).
  /// Ejemplo: `Sáb, 23 may · 09:00`
  static String compactDateTimeLine(EventModel event) {
    final d = event.start;
    final wd = _weekdays[d.weekday - DateTime.monday].substring(0, 3);
    final datePart = '$wd, ${d.day} ${_monthsShort[d.month - 1]}';
    return '$datePart · ${timeHm(d)}';
  }

  static String timeHm(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static int? durationMinutes(EventModel event) {
    if (event.durationMinutes != null && event.durationMinutes! > 0) {
      return event.durationMinutes;
    }
    final end = event.end;
    if (end != null) {
      final diff = end.difference(event.start).inMinutes;
      if (diff > 0) return diff;
    }
    return null;
  }

  static String timeRange(EventModel event) {
    final start = timeHm(event.start);
    final end = event.end;
    final mins = durationMinutes(event);
    if (end != null) {
      final endHm = timeHm(end);
      if (mins != null) return '$start–$endHm (${_durationText(mins)})';
      return '$start–$endHm';
    }
    if (mins != null) return '$start (${_durationText(mins)})';
    return start;
  }

  static String gapDuration(int minutes) => _durationText(minutes);

  static String _durationText(int minutes) {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) return h == 1 ? '1 h' : '$h h';
    return '$h h $m min';
  }

  static String notesText(EventModel event) {
    if (event.description.trim().isNotEmpty) return event.description.trim();
    return event.detail.trim();
  }
}
