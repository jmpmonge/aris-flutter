import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/intent_model.dart';
import '../models/local_action_model.dart';

/// Fuente única de acciones locales simuladas — memoria + persistencia opcional
/// vía [SharedPreferences] (JSON). Sin backend.
abstract final class LocalActionService {
  static const String _prefsKey = 'aris_local_actions_v1';

  static final List<LocalActionModel> _actions = [];

  /// Notifica creación, hidratación o borrado (refresco de pantallas).
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  /// Carga acciones guardadas. Llamar una vez al arranque (`main`), antes de `runApp`.
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      return;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final items = map['items'] as List<dynamic>? ?? [];
      _actions
        ..clear()
        ..addAll(
          items.map(
            (e) => LocalActionModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          ),
        );
      revision.value++;
    } catch (_) {
      _actions.clear();
      await prefs.remove(_prefsKey);
      revision.value++;
    }
  }

  /// Última acción creada (más reciente primero en la lista interna).
  static LocalActionModel? getMostRecentAction() =>
      _actions.isEmpty ? null : _actions.first;

  /// Copia inmutable, más recientes primero.
  static List<LocalActionModel> getRecentActions() =>
      List<LocalActionModel>.unmodifiable(_actions);

  static List<LocalActionModel> getActionsByType(LocalActionType type) =>
      _actions.where((a) => a.type == type).toList(growable: false);

  /// Solo `task`, `note`, `event`, `mail`. `general` y `unknown` → `null`.
  static LocalActionModel? createFromIntent(IntentModel intent) {
    final mapped = _typeFromIntent(intent.type);
    if (mapped == null) return null;

    final now = DateTime.now();
    final action = LocalActionModel(
      id: 'aris_local_${now.microsecondsSinceEpoch}',
      type: mapped,
      title: _deriveTitle(intent.originalText),
      description: _deriveDescription(mapped),
      sourceText: intent.originalText,
      createdAt: now,
      status: LocalActionStatus.simulated,
      optionalIntentConfidence: intent.confidence,
    );
    _actions.insert(0, action);
    revision.value++;
    _schedulePersist();
    return action;
  }

  /// Borra todas las acciones locales (demo / pruebas) y el almacenamiento.
  static Future<void> clearLocalActions() async {
    _actions.clear();
    revision.value++;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    } catch (_) {
      // Ignorado en demo.
    }
  }

  /// Alias obsoleto; preferir [clearLocalActions].
  @Deprecated('Usar clearLocalActions')
  static void clearAll() {
    unawaited(clearLocalActions());
  }

  static void _schedulePersist() {
    unawaited(_persist());
  }

  static Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode({
        'v': 1,
        'items': _actions.map((e) => e.toJson()).toList(),
      });
      await prefs.setString(_prefsKey, encoded);
    } catch (_) {
      // Sin registro; fallo de E/S no bloquea la demo.
    }
  }

  static LocalActionType? _typeFromIntent(IntentType t) {
    return switch (t) {
      IntentType.task => LocalActionType.task,
      IntentType.note => LocalActionType.note,
      IntentType.event => LocalActionType.event,
      IntentType.mail => LocalActionType.mail,
      _ => null,
    };
  }

  static String _deriveTitle(String source) {
    final t = source.trim();
    if (t.isEmpty) return 'Sin título';
    const max = 52;
    if (t.length <= max) return t;
    return '${t.substring(0, max - 1)}…';
  }

  static String _deriveDescription(LocalActionType type) {
    return switch (type) {
      LocalActionType.task =>
        'Tarea generada desde el chat local. Revísala cuando quieras.',
      LocalActionType.note =>
        'Nota capturada de forma simulada a partir de tu mensaje.',
      LocalActionType.event =>
        'Evento de demostración; más adelante podrá sincronizarse.',
      LocalActionType.mail =>
        'Borrador conceptual de acción sobre correo (sin bandeja real).',
      LocalActionType.general =>
        'Acción genérica local; sin canal externo conectado.',
    };
  }
}
