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
    _insert(action);
    return action;
  }

  /// Tarea desde formulario (estado [LocalActionStatus.pending]).
  static LocalActionModel createTask({
    required String title,
    String? description,
    LocalTaskPriority? priority,
  }) {
    final t = title.trim();
    if (t.isEmpty) {
      throw ArgumentError.value(title, 'title', 'No puede estar vacío');
    }
    final now = DateTime.now();
    final desc = description?.trim();
    final body = (desc == null || desc.isEmpty)
        ? 'Tarea creada desde el formulario local.'
        : desc;
    final action = LocalActionModel(
      id: 'aris_local_${now.microsecondsSinceEpoch}',
      type: LocalActionType.task,
      title: t,
      description: body,
      sourceText: 'formulario:tarea',
      createdAt: now,
      status: LocalActionStatus.pending,
      taskPriority: priority ?? LocalTaskPriority.medium,
    );
    _insert(action);
    return action;
  }

  /// Nota desde formulario.
  static LocalActionModel createNote({
    required String title,
    required String content,
    String? category,
  }) {
    final t = title.trim();
    if (t.isEmpty) {
      throw ArgumentError.value(title, 'title', 'No puede estar vacío');
    }
    final now = DateTime.now();
    final body = content.trim();
    final desc = body.isEmpty
        ? 'Nota creada desde el formulario local.'
        : body;
    final cat = category?.trim();
    final action = LocalActionModel(
      id: 'aris_local_${now.microsecondsSinceEpoch}',
      type: LocalActionType.note,
      title: t,
      description: desc,
      sourceText: 'formulario:nota',
      createdAt: now,
      status: LocalActionStatus.pending,
      noteCategory: (cat == null || cat.isEmpty) ? null : cat,
    );
    _insert(action);
    return action;
  }

  /// Evento desde formulario (fecha solo texto).
  static LocalActionModel createEvent({
    required String title,
    String? description,
    String? dateText,
  }) {
    final t = title.trim();
    if (t.isEmpty) {
      throw ArgumentError.value(title, 'title', 'No puede estar vacío');
    }
    final now = DateTime.now();
    final desc = description?.trim();
    final when = dateText?.trim();
    final parts = <String>[];
    if (desc != null && desc.isNotEmpty) parts.add(desc);
    if (when != null && when.isNotEmpty) {
      parts.add('Cuándo (simulado): $when');
    }
    if (parts.isEmpty) {
      parts.add('Evento creado desde el formulario local.');
    }
    final action = LocalActionModel(
      id: 'aris_local_${now.microsecondsSinceEpoch}',
      type: LocalActionType.event,
      title: t,
      description: parts.join('\n\n'),
      sourceText: 'formulario:evento',
      createdAt: now,
      status: LocalActionStatus.pending,
      eventWhenText: when,
    );
    _insert(action);
    return action;
  }

  /// Acción de correo simulada desde formulario.
  static LocalActionModel createMailAction({
    required String title,
    String? description,
  }) {
    final t = title.trim();
    if (t.isEmpty) {
      throw ArgumentError.value(title, 'asunto', 'No puede estar vacío');
    }
    final now = DateTime.now();
    final desc = description?.trim();
    final body = (desc == null || desc.isEmpty)
        ? 'Acción de correo simulada (sin envío real).'
        : desc;
    final action = LocalActionModel(
      id: 'aris_local_${now.microsecondsSinceEpoch}',
      type: LocalActionType.mail,
      title: t,
      description: body,
      sourceText: 'formulario:correo',
      createdAt: now,
      status: LocalActionStatus.pending,
    );
    _insert(action);
    return action;
  }

  /// Elimina una acción por identificador.
  static void removeAction(String id) {
    _actions.removeWhere((a) => a.id == id);
    revision.value++;
    _schedulePersist();
  }

  /// Completa o reabre tarea / acción mail.
  static void toggleActionCompleted(String id) {
    final i = _actions.indexWhere((a) => a.id == id);
    if (i < 0) return;
    final a = _actions[i];
    if (a.type != LocalActionType.task && a.type != LocalActionType.mail) {
      return;
    }
    final next = a.status == LocalActionStatus.completed
        ? LocalActionStatus.pending
        : LocalActionStatus.completed;
    _actions[i] = a.copyWith(status: next);
    revision.value++;
    _schedulePersist();
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

  static void _insert(LocalActionModel action) {
    _actions.insert(0, action);
    revision.value++;
    _schedulePersist();
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
