import '../models/intent_model.dart';

/// Clasificación por **palabras clave** (español). Sin modelos de ML ni red.
abstract final class IntentClassifierService {
  /// Orden: tarea → nota → evento → correo: primera categoría con coincidencia gana.
  static const List<String> _taskKeys = [
    'recuérdame',
    'recuerdame',
    'tengo que',
    'pendiente',
    'hacer',
    'llamar',
    'comprar',
  ];

  static const List<String> _noteKeys = [
    'nota',
    'apunta',
    'guardar idea',
    'idea',
    'anotar',
  ];

  static const List<String> _eventKeys = [
    'mañana',
    'manana',
    'hoy a',
    'reunión',
    'reunion',
    'cita',
    'calendario',
    'a las',
  ];

  static const List<String> _mailKeys = [
    'correo',
    'email',
    'mail',
    'responder',
    'enviar correo',
  ];

  static IntentModel classify(String rawText) {
    final original = rawText.trim();
    if (original.isEmpty) {
      return IntentModel(
        type: IntentType.unknown,
        confidence: 0,
        originalText: rawText,
        explanation: 'Texto vacío',
      );
    }

    final t = original.toLowerCase();

    IntentModel? tryMatch(IntentType type, List<String> keys) {
      String? matched;
      for (final k in keys) {
        if (t.contains(k)) {
          matched = k;
          break;
        }
      }
      if (matched == null) return null;
      final base = 0.72 + (matched.length / original.length).clamp(0.0, 0.26);
      final jitter = (original.hashCode.abs() % 7) / 100.0;
      final conf = (base + jitter).clamp(0.0, 1.0);
      return IntentModel(
        type: type,
        confidence: conf,
        originalText: original,
        explanation: 'Coincidencia: "$matched"',
      );
    }

    return tryMatch(IntentType.task, _taskKeys) ??
        tryMatch(IntentType.note, _noteKeys) ??
        tryMatch(IntentType.event, _eventKeys) ??
        tryMatch(IntentType.mail, _mailKeys) ??
        IntentModel(
          type: IntentType.general,
          confidence: 0.55,
          originalText: original,
          explanation: 'Sin palabras clave concretas',
        );
  }
}
