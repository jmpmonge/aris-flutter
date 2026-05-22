/// Tarea en cliente (**GET /tasks**).
class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    this.completed = false,
    this.dueDate,
    this.description,
    this.tags = const [],
    this.priority,
    this.dateIso,
    this.dateText,
    this.timeText,
  });

  final String id;
  /// Sólo título desde backend (**compacto**: sin mezcla de descripción/hora legada).
  final String title;
  final bool completed;
  /// Sólo **mocks locales** cuando no hay `date_iso` / `date_text` de backend.
  final DateTime? dueDate;

  final String? description;
  final List<String> tags;
  final String? priority;
  final String? dateIso;
  final String? dateText;
  final String? timeText;

  /// Texto de notas/descripción para ficha desplegada (campo `description`).
  static String expandedDescription(TaskModel task) {
    return (task.description ?? '').trim();
  }

  /// Interpreta **`YYYY-MM-DD`** como día civil **local**.
  static DateTime? tryParseIsoDateLocal(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final re = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
    final m = re.firstMatch(raw.trim());
    if (m == null) return null;
    final y = int.tryParse(m.group(1)!);
    final mo = int.tryParse(m.group(2)!);
    final d = int.tryParse(m.group(3)!);
    if (y == null || mo == null || d == null) return null;
    return DateTime(y, mo, d);
  }

  TaskModel copyWith({
    String? id,
    String? title,
    bool? completed,
    DateTime? dueDate,
    String? description,
    List<String>? tags,
    String? priority,
    String? dateIso,
    String? dateText,
    String? timeText,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      dueDate: dueDate ?? this.dueDate,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
      dateIso: dateIso ?? this.dateIso,
      dateText: dateText ?? this.dateText,
      timeText: timeText ?? this.timeText,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'completed': completed,
    if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
    if (description != null) 'description': description,
    'tags': tags,
    if (priority != null) 'priority': priority,
    if (dateIso != null) 'dateIso': dateIso,
    if (dateText != null) 'dateText': dateText,
    if (timeText != null) 'timeText': timeText,
  };

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      completed: json['completed'] as bool? ?? false,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      description: json['description'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      priority: json['priority'] as String?,
      dateIso: json['dateIso'] as String?,
      dateText: json['dateText'] as String?,
      timeText: json['timeText'] as String?,
    );
  }
}
