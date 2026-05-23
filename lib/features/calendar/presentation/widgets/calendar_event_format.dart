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

  /// Título mes/año para cabecera Semana (v0.49.70).
  static String monthYearTitle(DateTime anchor) {
    final name = _months[anchor.month - 1];
    final capitalized = name.isEmpty ? name : '${name[0].toUpperCase()}${name.substring(1)}';
    return '$capitalized ${anchor.year}';
  }

  /// Subtítulo compacto tarjeta inferior Semana: «09:00 · Lugar» o rango horario.
  static String weekSelectedCardSubtitle(EventModel event) {
    final timePart = _weekCardTimePart(event);
    final loc = event.location.trim();
    if (loc.isNotEmpty) return '$timePart · $loc';
    final fallbackLoc = expandedLocation(event);
    if (fallbackLoc != null && fallbackLoc != event.title.trim()) {
      return '$timePart · $fallbackLoc';
    }
    return timePart;
  }

  static String _weekCardTimePart(EventModel event) {
    final start = timeHm(event.start);
    final end = event.end;
    if (end != null && end.isAfter(event.start)) {
      return '$start – ${timeHm(end)}';
    }
    final mins = durationMinutes(event);
    if (mins != null && mins > 0) {
      final endCalc = event.start.add(Duration(minutes: mins));
      return '$start – ${timeHm(endCalc)}';
    }
    return start;
  }

  static String shortDate(EventModel event) {
    if (event.dateText.trim().isNotEmpty) return event.dateText.trim();
    final d = event.start;
    final wd = _weekdays[d.weekday - DateTime.monday].substring(0, 3);
    return '$wd, ${d.day} ${_monthsShort[d.month - 1]} ${d.year}';
  }

  /// Ubicación para tarjeta expandida Día (v0.49.63).
  static String? expandedLocation(EventModel event) {
    final loc = event.location.trim();
    if (loc.isNotEmpty) return loc;
    if (event.description.trim().isNotEmpty) return null;
    final detail = event.detail.trim();
    return detail.isNotEmpty ? detail : null;
  }

  /// Observaciones para tarjeta expandida Día (v0.49.63).
  static String? expandedObservations(EventModel event) {
    final desc = event.description.trim();
    return desc.isNotEmpty ? desc : null;
  }

  /// Aviso/alarma para tarjeta expandida Día (v0.49.64).
  /// Solo devuelve texto si el evento tiene minutos de aviso configurados.
  static String? expandedReminder(EventModel event) {
    return reminderLabel(_reminderMinutesBefore(event));
  }

  static int? _reminderMinutesBefore(EventModel event) {
    if (event.reminderMinutesBefore != null &&
        event.reminderMinutesBefore! > 0) {
      return event.reminderMinutesBefore;
    }
    return null;
  }

  /// Etiqueta legible de aviso: «Aviso 15 min antes», «Aviso 1 h antes», etc.
  static String? reminderLabel(int? minutesBefore) {
    if (minutesBefore == null || minutesBefore <= 0) return null;
    if (minutesBefore >= 1440 && minutesBefore % 1440 == 0) {
      final days = minutesBefore ~/ 1440;
      final unit = days == 1 ? '1 día' : '$days días';
      return 'Aviso $unit antes';
    }
    if (minutesBefore >= 60 && minutesBefore % 60 == 0) {
      final hours = minutesBefore ~/ 60;
      final unit = hours == 1 ? '1 h' : '$hours h';
      return 'Aviso $unit antes';
    }
    return 'Aviso $minutesBefore min antes';
  }

  /// Opciones cortas para chip y selector de alarma (v0.49.67).
  static const List<MapEntry<int?, String>> reminderChipOptions = [
    MapEntry(null, 'Sin aviso'),
    MapEntry(5, '5 min'),
    MapEntry(10, '10 min'),
    MapEntry(15, '15 min'),
    MapEntry(30, '30 min'),
    MapEntry(60, '1 h'),
    MapEntry(1440, '1 día'),
  ];

  static String reminderEditLabel(int? minutesBefore) {
    for (final o in reminderChipOptions) {
      if (o.key == minutesBefore) return o.value;
    }
    return reminderChipLabel(minutesBefore) ?? 'Sin aviso';
  }

  /// Etiqueta corta para chip de alarma en editor (v0.49.67).
  static String? reminderChipLabel(int? minutesBefore) {
    if (minutesBefore == null || minutesBefore <= 0) return null;
    for (final o in reminderChipOptions) {
      if (o.key == minutesBefore) return o.value;
    }
    if (minutesBefore >= 1440 && minutesBefore % 1440 == 0) {
      final days = minutesBefore ~/ 1440;
      return days == 1 ? '1 día' : '$days días';
    }
    if (minutesBefore >= 60 && minutesBefore % 60 == 0) {
      final hours = minutesBefore ~/ 60;
      return hours == 1 ? '1 h' : '$hours h';
    }
    return '$minutesBefore min';
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
