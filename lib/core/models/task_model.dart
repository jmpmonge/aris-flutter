/// Tarea (solo cliente; persistencia pendiente de backend).
class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    this.completed = false,
    this.dueDate,
  });

  final String id;
  final String title;
  final bool completed;
  final DateTime? dueDate;

  TaskModel copyWith({
    String? id,
    String? title,
    bool? completed,
    DateTime? dueDate,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'completed': completed,
    if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
  };

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      completed: json['completed'] as bool? ?? false,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
    );
  }
}
