import 'package:flutter/material.dart';

import '../../../core/models/event_model.dart';

/// Icono + etiqueta para bloques de la rejilla Semana (v0.49.6).
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

/// Resuelve badge semanal: campos backend opcionales o fallback fijo.
abstract final class CalendarWeekEventBadgeResolver {
  CalendarWeekEventBadgeResolver._();

  static const int _maxLabelChars = 9;

  static const Map<String, IconData> _iconByBackendKey = {
    'cafe': Icons.local_cafe_outlined,
    'café': Icons.local_cafe_outlined,
    'sync': Icons.sync_rounded,
    'comer': Icons.restaurant_outlined,
    'comida': Icons.restaurant_outlined,
    'envio': Icons.send_rounded,
    'envío': Icons.send_rounded,
    'gym': Icons.fitness_center_outlined,
    'super': Icons.shopping_cart_outlined,
    'evento': Icons.event_rounded,
  };

  static CalendarWeekEventBadge resolve(EventModel event) {
    final iconKey = event.weekIconKey?.trim();
    final labelText = event.weekLabelText?.trim();
    final hasIconKey = iconKey != null && iconKey.isNotEmpty;
    final hasLabelText = labelText != null && labelText.isNotEmpty;

    if (hasIconKey || hasLabelText) {
      return CalendarWeekEventBadge(
        icon: _iconFromBackendKey(iconKey) ?? Icons.event_rounded,
        label: _clipLabel(hasLabelText ? labelText : 'Evento'),
        fromBackendFields: true,
      );
    }

    return CalendarWeekEventBadge(
      icon: Icons.event_rounded,
      label: _clipLabel(_fallbackLabelFromTitle(event.title)),
      fromBackendFields: false,
    );
  }

  static IconData? _iconFromBackendKey(String? key) {
    if (key == null || key.isEmpty) return null;
    return _iconByBackendKey[key.toLowerCase()];
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
