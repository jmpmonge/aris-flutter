/// Nota breve (solo cliente).
class NoteModel {
  const NoteModel({
    required this.id,
    required this.title,
    required this.body,
    this.quickLabel,
    this.pinned = false,
    this.listTimeLabel,
    this.hasAttachments = false,
    this.attachmentName,
    this.hasChecklist = false,
    this.checklistItemCount = 0,
    this.folderName,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String body;

  /// Etiqueta legacy (chips). Si [tags] está vacío, se muestra en listado como #tag.
  final String? quickLabel;

  /// Etiquetas en listado (v0.49.43), p. ej. `aris` → `#aris`.
  final List<String> tags;

  /// Fijada en listado (v0.49.43). Persistencia backend: futuro.
  final bool pinned;

  /// Hora o «Hoy, 12:48» en la tarjeta del listado.
  final String? listTimeLabel;

  final bool hasAttachments;
  final String? attachmentName;
  final bool hasChecklist;
  final int checklistItemCount;

  /// Carpeta; no se muestra si es la general o «Notas».
  final String? folderName;

  bool get showFolderInList {
    final f = folderName?.trim();
    if (f == null || f.isEmpty) return false;
    final lower = f.toLowerCase();
    return lower != 'notas' && lower != 'general' && lower != 'todas';
  }

  static String normalizeListTag(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return '';
    return s.startsWith('#') ? s : '#$s';
  }

  /// Etiquetas normalizadas para la fila inferior del listado.
  List<String> get listDisplayTags {
    final out = <String>[];
    for (final tag in tags) {
      final n = normalizeListTag(tag);
      if (n.isNotEmpty && !out.contains(n)) out.add(n);
    }
    if (out.isEmpty && quickLabel != null && quickLabel!.trim().isNotEmpty) {
      out.add(normalizeListTag(quickLabel!));
    }
    return out;
  }

  /// Fila inferior del listado: solo adjunto y etiquetas (sin checklist).
  bool get hasListMetadataRow =>
      hasAttachments || listDisplayTags.isNotEmpty;

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
    if (listTimeLabel != null) 'listTimeLabel': listTimeLabel,
    if (hasAttachments) 'hasAttachments': true,
    if (attachmentName != null) 'attachmentName': attachmentName,
    if (hasChecklist) 'hasChecklist': true,
    if (checklistItemCount > 0) 'checklistItemCount': checklistItemCount,
    if (folderName != null) 'folderName': folderName,
    if (tags.isNotEmpty) 'tags': tags,
  };

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    final pinnedRaw = json['pinned'] ?? json['isPinned'] ?? json['fixed'];
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String? ?? '',
      quickLabel: json['quickLabel'] as String?,
      pinned: pinnedRaw == true,
      listTimeLabel: json['listTimeLabel'] as String?,
      hasAttachments: json['hasAttachments'] == true,
      attachmentName: json['attachmentName'] as String?,
      hasChecklist: json['hasChecklist'] == true,
      checklistItemCount: json['checklistItemCount'] as int? ?? 0,
      folderName: json['folderName'] as String?,
      tags: _parseTags(json),
    );
  }

  static List<String> _parseTags(Map<String, dynamic> json) {
    final raw = json['tags'];
    if (raw is List) {
      return [
        for (final item in raw)
          if (item is String && item.trim().isNotEmpty) item.trim(),
      ];
    }
    return const [];
  }
}
