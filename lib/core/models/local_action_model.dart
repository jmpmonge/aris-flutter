import 'package:flutter/foundation.dart';

/// Tipo de acción materializada localmente (sin backend).
enum LocalActionType { task, note, event, mail, general }

/// Estado de la acción en la demo (sin persistencia real).
enum LocalActionStatus { simulated, pending, completed }

/// Prioridad visual opcional para tareas creadas desde formulario.
enum LocalTaskPriority { low, medium, high }

extension LocalTaskPriorityLabels on LocalTaskPriority {
  String get displayLabel => switch (this) {
        LocalTaskPriority.low => 'Baja',
        LocalTaskPriority.medium => 'Media',
        LocalTaskPriority.high => 'Alta',
      };
}

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
    this.taskPriority,
    this.noteCategory,
    this.eventWhenText,
  });

  final String id;
  final LocalActionType type;
  final String title;
  final String description;
  final String sourceText;
  final DateTime createdAt;
  final LocalActionStatus status;
  final double? optionalIntentConfidence;

  /// Solo tareas desde formulario / UI extendida.
  final LocalTaskPriority? taskPriority;

  /// Etiqueta libre (p. ej. Trabajo, Personal, Ideas).
  final String? noteCategory;

  /// Referencia temporal en texto (sin date picker real).
  final String? eventWhenText;

  String get typeShortLabel => switch (type) {
        LocalActionType.task => 'TAREA',
        LocalActionType.note => 'NOTA',
        LocalActionType.event => 'EVENTO',
        LocalActionType.mail => 'MAIL',
        LocalActionType.general => 'GENERAL',
      };

  String get statusChipLabel => switch (status) {
        LocalActionStatus.simulated => 'SIMULADO',
        LocalActionStatus.pending => 'PENDIENTE',
        LocalActionStatus.completed => 'LISTO',
      };

  /// Etiqueta humana del flujo (chat vs formulario vs hecho).
  String get operationalStatusLabel => switch (status) {
        LocalActionStatus.simulated => 'Desde chat',
        LocalActionStatus.pending => 'Pendiente',
        LocalActionStatus.completed => 'Listo',
      };

  LocalActionModel copyWith({
    String? id,
    LocalActionType? type,
    String? title,
    String? description,
    String? sourceText,
    DateTime? createdAt,
    LocalActionStatus? status,
    double? optionalIntentConfidence,
    LocalTaskPriority? taskPriority,
    String? noteCategory,
    String? eventWhenText,
  }) {
    return LocalActionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      sourceText: sourceText ?? this.sourceText,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      optionalIntentConfidence:
          optionalIntentConfidence ?? this.optionalIntentConfidence,
      taskPriority: taskPriority ?? this.taskPriority,
      noteCategory: noteCategory ?? this.noteCategory,
      eventWhenText: eventWhenText ?? this.eventWhenText,
    );
  }

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
        if (taskPriority != null) 'taskPriority': taskPriority!.name,
        if (noteCategory != null) 'noteCategory': noteCategory,
        if (eventWhenText != null) 'eventWhenText': eventWhenText,
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
      taskPriority: json['taskPriority'] != null
          ? LocalTaskPriority.values.byName(json['taskPriority'] as String)
          : null,
      noteCategory: json['noteCategory'] as String?,
      eventWhenText: json['eventWhenText'] as String?,
    );
  }
}
