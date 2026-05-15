import 'package:flutter/foundation.dart';

import '../models/intent_model.dart';
import '../models/local_action_model.dart';

/// Acciones locales **solo en memoria** (demo). Sin base de datos ni API.
abstract final class LocalActionService {
  static final List<LocalActionModel> _actions = [];

  /// Notifica creación o limpieza de acciones (p. ej. para refrescar pantallas).
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

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
    return action;
  }

  /// Reinicio para pruebas o demos; no borra chat ni otros servicios.
  static void clearAll() {
    _actions.clear();
    revision.value++;
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
