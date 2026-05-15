import 'package:flutter/foundation.dart';

/// Intención inferida localmente (sin IA ni servidor).
enum IntentType { task, note, event, mail, general, unknown }

@immutable
class IntentModel {
  const IntentModel({
    required this.type,
    required this.confidence,
    required this.originalText,
    this.explanation,
  });

  final IntentType type;
  final double confidence;
  final String originalText;
  final String? explanation;

  /// Etiqueta corta para chip en conversación (mayúsculas).
  String get chipLabel => switch (type) {
        IntentType.task => 'TAREA',
        IntentType.note => 'NOTA',
        IntentType.event => 'EVENTO',
        IntentType.mail => 'MAIL',
        IntentType.general => 'GENERAL',
        IntentType.unknown => 'DESCONOCIDO',
      };

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'confidence': confidence,
        'originalText': originalText,
        if (explanation != null) 'explanation': explanation,
      };

  factory IntentModel.fromJson(Map<String, dynamic> json) {
    return IntentModel(
      type: IntentType.values.byName(json['type'] as String),
      confidence: (json['confidence'] as num).toDouble(),
      originalText: json['originalText'] as String,
      explanation: json['explanation'] as String?,
    );
  }
}
