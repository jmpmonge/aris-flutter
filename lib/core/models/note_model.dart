/// Nota breve (solo cliente).
class NoteModel {
  const NoteModel({
    required this.id,
    required this.title,
    required this.body,
    this.quickLabel,
  });

  final String id;
  final String title;
  final String body;

  /// Etiqueta opcional para chips rápidos (ej. «Compra»).
  final String? quickLabel;

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
  };

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String? ?? '',
      quickLabel: json['quickLabel'] as String?,
    );
  }
}
