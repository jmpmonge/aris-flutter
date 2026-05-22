/// Nota breve (solo cliente).
class NoteModel {
  const NoteModel({
    required this.id,
    required this.title,
    required this.body,
    this.quickLabel,
    this.pinned = false,
  });

  final String id;
  final String title;
  final String body;

  /// Etiqueta opcional para chips rápidos (ej. «Compra»).
  final String? quickLabel;

  /// Fijada en listado (v0.49.43). Persistencia backend: futuro.
  final bool pinned;

  /// Línea compacta tipo Home.
  String get homePreviewLine {
    if (body.isEmpty) return title;
    return '$title: ${body.length > 48 ? '${body.substring(0, 48)}…' : body}';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    if (quickLabel != null) 'quickLabel': quickLabel,
    if (pinned) 'pinned': true,
  };

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    final pinnedRaw = json['pinned'] ?? json['isPinned'] ?? json['fixed'];
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String? ?? '',
      quickLabel: json['quickLabel'] as String?,
      pinned: pinnedRaw == true,
    );
  }
}
