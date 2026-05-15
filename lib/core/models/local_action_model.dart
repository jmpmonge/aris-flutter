import 'package:flutter/foundation.dart';

/// Tipo de acción materializada localmente (sin backend).
enum LocalActionType { task, note, event, mail, general }

/// Estado de la acción en la demo (sin persistencia real).
enum LocalActionStatus { simulated, pending, completed }

@immutable
class LocalActionModel {
  const LocalActionModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.sourceText,
    required this.createdAt,
    this.status = LocalActionStatus.simulated,
    this.optionalIntentConfidence,
  });

  final String id;
  final LocalActionType type;
  final String title;
  final String description;
  final String sourceText;
  final DateTime createdAt;
  final LocalActionStatus status;
  final double? optionalIntentConfidence;

  String get typeShortLabel => switch (type) {
        LocalActionType.task => 'TAREA',
        LocalActionType.note => 'NOTA',
        LocalActionType.event => 'EVENTO',
        LocalActionType.mail => 'MAIL',
        LocalActionType.general => 'GENERAL',
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'description': description,
        'sourceText': sourceText,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        if (optionalIntentConfidence != null)
          'optionalIntentConfidence': optionalIntentConfidence,
      };

  factory LocalActionModel.fromJson(Map<String, dynamic> json) {
    return LocalActionModel(
      id: json['id'] as String,
      type: LocalActionType.values.byName(json['type'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      sourceText: json['sourceText'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: LocalActionStatus.values.byName(
        json['status'] as String? ?? LocalActionStatus.simulated.name,
      ),
      optionalIntentConfidence:
          (json['optionalIntentConfidence'] as num?)?.toDouble(),
    );
  }
}
