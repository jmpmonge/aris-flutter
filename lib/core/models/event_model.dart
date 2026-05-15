/// Evento de agenda (solo cliente; sin acoplar a proveedor de calendario).
class EventModel {
  const EventModel({
    required this.id,
    required this.start,
    this.end,
    required this.title,
    this.detail = '',
  });

  final String id;
  final DateTime start;
  final DateTime? end;
  final String title;
  final String detail;

  /// Línea compacta para listas tipo Home (hora + título + detalle).
  String get homePreviewLine {
    final h = start.hour.toString().padLeft(2, '0');
    final m = start.minute.toString().padLeft(2, '0');
    if (detail.isEmpty) return '$h:$m · $title';
    return '$h:$m · $title ($detail)';
  }

  String get timeHm {
    final h = start.hour.toString().padLeft(2, '0');
    final m = start.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'start': start.toIso8601String(),
    if (end != null) 'end': end!.toIso8601String(),
    'title': title,
    'detail': detail,
  };

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      start: DateTime.parse(json['start'] as String),
      end: json['end'] != null ? DateTime.parse(json['end'] as String) : null,
      title: json['title'] as String,
      detail: json['detail'] as String? ?? '',
    );
  }
}
