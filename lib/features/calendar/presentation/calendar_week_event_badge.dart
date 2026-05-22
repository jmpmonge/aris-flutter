import 'package:flutter/material.dart';

import '../../../core/models/event_model.dart';
import 'widgets/calendar_event_icon.dart';

/// Icono + etiqueta para bloques de la rejilla Semana (v0.49.45).
class CalendarWeekEventBadge {
  const CalendarWeekEventBadge({
    required this.icon,
    required this.label,
    required this.fromBackendFields,
  });

  final IconData icon;
  final String label;

  /// `true` si al menos uno de `icono_semana` / `texto_semana` venía en el dato.
  final bool fromBackendFields;
}

/// Resuelve badge semanal: campos backend opcionales o inferencia local.
abstract final class CalendarWeekEventBadgeResolver {
  CalendarWeekEventBadgeResolver._();

  static const int _maxLabelChars = 8;

  static CalendarWeekEventBadge resolve(EventModel event) {
    final iconKey = event.weekIconKey?.trim();
    final labelText = event.weekLabelText?.trim();
    final hasIconKey = iconKey != null && iconKey.isNotEmpty;
    final hasLabelText = labelText != null && labelText.isNotEmpty;

    if (hasIconKey || hasLabelText) {
      return CalendarWeekEventBadge(
        icon: CalendarEventIconResolver.resolve(event),
        label: _clipLabel(
          hasLabelText ? labelText : _fallbackLabelFromTitle(event.title),
        ),
        fromBackendFields: true,
      );
    }

    return CalendarWeekEventBadge(
      icon: CalendarEventIconResolver.resolve(event),
      label: _clipLabel(_fallbackLabelFromTitle(event.title)),
      fromBackendFields: false,
    );
  }

  static String _fallbackLabelFromTitle(String title) {
    final t = title.trim();
    if (t.isEmpty) return '·';
    final first = t.split(RegExp(r'\s+')).first;
    return first;
  }

  static String _clipLabel(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return '·';
    if (t.length <= _maxLabelChars) return t;
    return '${t.substring(0, _maxLabelChars - 1)}…';
  }
}
