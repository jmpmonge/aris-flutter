import 'package:flutter/material.dart';

import '../../../../core/models/event_model.dart';

/// Icono automático de evento (v0.49.45).
abstract final class CalendarEventIconResolver {
  CalendarEventIconResolver._();

  static const Map<String, IconData> _iconByKey = {
    'coffee': Icons.local_cafe_outlined,
    'cafe': Icons.local_cafe_outlined,
    'café': Icons.local_cafe_outlined,
    'sync': Icons.sync_rounded,
    'meeting': Icons.groups_outlined,
    'cita': Icons.groups_outlined,
    'reunion': Icons.groups_outlined,
    'reunión': Icons.groups_outlined,
    'meal': Icons.restaurant_outlined,
    'comer': Icons.restaurant_outlined,
    'comida': Icons.restaurant_outlined,
    'almuerzo': Icons.restaurant_outlined,
    'send': Icons.local_shipping_outlined,
    'envio': Icons.local_shipping_outlined,
    'envío': Icons.local_shipping_outlined,
    'paquete': Icons.local_shipping_outlined,
    'gym': Icons.fitness_center_outlined,
    'deporte': Icons.fitness_center_outlined,
    'pilates': Icons.self_improvement_outlined,
    'salud': Icons.favorite_outline_rounded,
    'shopping': Icons.shopping_cart_outlined,
    'super': Icons.shopping_cart_outlined,
    'compra': Icons.shopping_cart_outlined,
    'work': Icons.work_outline_rounded,
    'trabajo': Icons.work_outline_rounded,
    'rest': Icons.nightlight_round_outlined,
    'descanso': Icons.nightlight_round_outlined,
    'desconexion': Icons.nightlight_round_outlined,
    'desconexión': Icons.nightlight_round_outlined,
    'evento': Icons.event_rounded,
  };

  static IconData resolve(EventModel event) {
    final backend = event.weekIconKey?.trim().toLowerCase();
    if (backend != null && backend.isNotEmpty) {
      return _iconByKey[backend] ?? Icons.event_rounded;
    }
    return _inferFromText('${event.title} ${event.description} ${event.detail}');
  }

  static String categoryLabel(EventModel event) {
    final backend = event.weekLabelText?.trim();
    if (backend != null && backend.isNotEmpty) return backend;
    return _categoryFromIcon(resolve(event));
  }

  static IconData _inferFromText(String raw) {
    final t = raw.toLowerCase();
    if (_containsAny(t, ['reunión', 'reunion', 'cita', 'sync', 'equipo'])) {
      return Icons.groups_outlined;
    }
    if (_containsAny(t, ['enviar', 'envío', 'envio', 'paquete', 'correo'])) {
      return Icons.local_shipping_outlined;
    }
    if (_containsAny(t, ['compra', 'super', 'mercado', 'shopping'])) {
      return Icons.shopping_cart_outlined;
    }
    if (_containsAny(t, ['pilates', 'gym', 'deporte', 'entren', 'salud'])) {
      return Icons.fitness_center_outlined;
    }
    if (_containsAny(t, ['comida', 'comer', 'almuerzo', 'cena', 'desayuno'])) {
      return Icons.restaurant_outlined;
    }
    if (_containsAny(t, ['trabajo', 'oficina', 'informe', 'proyecto'])) {
      return Icons.work_outline_rounded;
    }
    if (_containsAny(t, ['descanso', 'desconex', 'dormir', 'levantarse'])) {
      return Icons.nightlight_round_outlined;
    }
    return Icons.event_rounded;
  }

  static String _categoryFromIcon(IconData icon) {
    if (icon == Icons.groups_outlined) return 'Trabajo';
    if (icon == Icons.local_shipping_outlined) return 'Envío';
    if (icon == Icons.shopping_cart_outlined) return 'Compra';
    if (icon == Icons.fitness_center_outlined ||
        icon == Icons.self_improvement_outlined) {
      return 'Salud';
    }
    if (icon == Icons.restaurant_outlined) return 'Comida';
    if (icon == Icons.work_outline_rounded) return 'Trabajo';
    if (icon == Icons.nightlight_round_outlined) return 'Descanso';
    return 'Evento';
  }

  static bool _containsAny(String haystack, List<String> needles) {
    for (final n in needles) {
      if (haystack.contains(n)) return true;
    }
    return false;
  }
}
