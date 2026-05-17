/// Utilidades fecha/hora tolerantes desde JSON backend (textos libres o ISO).
abstract final class BackendDateTimeHints {
  static DateTime? tryParseIso(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  static DateTime? parseDateFlexible(Object? value) {
    if (value == null) return null;
    final s = value.toString().trim();
    if (s.isEmpty) return null;

    final iso = DateTime.tryParse(s);
    if (iso != null) return DateTime.utc(iso.year, iso.month, iso.day);

    final slash = RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})');
    final mSlash = slash.firstMatch(s);
    if (mSlash != null) {
      final a = int.tryParse(mSlash.group(1)!)!;
      final b = int.tryParse(mSlash.group(2)!)!;
      var y = int.tryParse(mSlash.group(3)!)!;
      if (y < 100) y += 2000;

      if (_validMd(y, b, a)) return DateTime.utc(y, b, a);
      if (_validMd(y, a, b)) return DateTime.utc(y, a, b);
    }

    final dash =
        RegExp(r'^\s*(\d{4})-(\d{2})-(\d{2})\s*$').firstMatch(s);
    if (dash != null) {
      final yy = int.parse(dash.group(1)!);
      final mm = int.parse(dash.group(2)!);
      final dd = int.parse(dash.group(3)!);
      if (_validMd(yy, mm, dd)) return DateTime.utc(yy, mm, dd);
    }

    return null;
  }

  static bool _validMd(int y, int m, int d) {
    if (m < 1 || m > 12 || d < 1 || d > 31 || y < 1970 || y > 2199) {
      return false;
    }
    return true;
  }

  static ResolvedClock parseTimeFlexible(Object? value) {
    if (value == null) return const ResolvedClock(12, 0);
    final s = value.toString().trim().toLowerCase();

    final m = RegExp(r'(\d{1,2})[:.](\d{2})').firstMatch(s);
    if (m != null) {
      final hh =
          _clampHour(int.tryParse(m.group(1)!.trim()) ?? 12);
      final mm =
          _clampMin(int.tryParse(m.group(2)!.trim()) ?? 0);
      return ResolvedClock(hh, mm);
    }

    final hOnly = RegExp(r'^\s*(\d{1,2})\s*$').firstMatch(s);
    if (hOnly != null) {
      final hh =
          _clampHour(int.tryParse(hOnly.group(1)!.trim()) ?? 12);
      return ResolvedClock(hh, 0);
    }

    final hBare = RegExp(r'\b(\d{1,2})\s*h').firstMatch(s);
    if (hBare != null) {
      return ResolvedClock(
        _clampHour(int.tryParse(hBare.group(1)!.trim()) ?? 12),
        0,
      );
    }

    return const ResolvedClock(12, 0);
  }

  static int _clampHour(int h) => h.clamp(0, 23);
  static int _clampMin(int mm) => mm.clamp(0, 59);

  /// Sentinel de día civil **no sustituye** fecha textual del servidor.
  ///
  /// [start] combina día + hora; [hasCivilCalendarDate] indica si el día debe
  /// usarse en rejillas día/semana/mes (**false** ⇒ mostrar sólo `date_text`).
  static BackendResolvedEventInstant resolveEventInstant({
    required Map<String, dynamic> data,
    required DateTime fallbackCalendarDay,
  }) {
    final rawDate = data['date_text']?.toString().trim() ?? '';
    DateTime datePartUtc;
    final bool hasCivil;

    final parsedFlexible =
        BackendDateTimeHints.parseDateFlexible(data['date_text']);
    if (parsedFlexible != null) {
      datePartUtc = parsedFlexible.toUtc();
      hasCivil = true;
    } else if (rawDate.isNotEmpty) {
      // Texto («lunes», «mañana», …): no usar `created_at` ni día corriente.
      datePartUtc = DateTime.utc(2000, 1, 1);
      hasCivil = false;
    } else {
      // Sin `date_text`: anclaje civil explícito (sin `created_at` como día).
      datePartUtc = DateTime.utc(
        fallbackCalendarDay.year,
        fallbackCalendarDay.month,
        fallbackCalendarDay.day,
      );
      hasCivil = true;
    }

    final clock = BackendDateTimeHints.parseTimeFlexible(data['time_text']);
    // Hora civil del backend (`time_text` sin zona): constructor local, no
    // DateTime.utc(...).toLocal() (evita desfase por huso p. ej. 19→14).
    final instant = DateTime(
      datePartUtc.year,
      datePartUtc.month,
      datePartUtc.day,
      clock.hour,
      clock.minute,
    );
    return BackendResolvedEventInstant(
      start: instant,
      hasCivilCalendarDate: hasCivil,
    );
  }

  /// Compatibilidad — preferí [resolveEventInstant].
  static DateTime approximateEventStart({
    required Map<String, dynamic> data,
    required DateTime fallbackCalendarDay,
  }) {
    return resolveEventInstant(
      data: data,
      fallbackCalendarDay: fallbackCalendarDay,
    ).start;
  }
}

/// Resultado de unir día + hora del JSON de `/events`.
final class BackendResolvedEventInstant {
  const BackendResolvedEventInstant({
    required this.start,
    required this.hasCivilCalendarDate,
  });

  final DateTime start;
  /// `false` si `date_text` es texto sin parseo civil (ej. «lunes»).
  final bool hasCivilCalendarDate;
}

class ResolvedClock {
  const ResolvedClock(this.hour, this.minute);
  final int hour;
  final int minute;
}
