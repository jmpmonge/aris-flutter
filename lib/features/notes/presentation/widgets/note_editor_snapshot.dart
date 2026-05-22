import 'note_body_format.dart';

/// Instantánea del contenido editable de la nota amplia (deshacer / rehacer).
final class NoteEditorSnapshot {
  const NoteEditorSnapshot({
    required this.title,
    required this.checklist,
    required this.segments,
  });

  final String title;
  final List<NoteChecklistItem> checklist;
  final List<NoteBodySegment> segments;

  static NoteEditorSnapshot fromDocument({
    required String title,
    required List<NoteChecklistItem> checklist,
    required List<NoteBodySegment> segments,
  }) {
    return NoteEditorSnapshot(
      title: title,
      checklist: [
        for (final item in checklist)
          NoteChecklistItem(text: item.text, done: item.done),
      ],
      segments: [
        for (final segment in segments)
          if (segment.isProse)
            NoteBodySegment.prose(segment.text!)
          else
            NoteBodySegment.table(
              NoteTableBlock(
                columns: segment.table!.columns,
                rows: [
                  for (final row in segment.table!.rows)
                    List<String>.from(row),
                ],
              ),
            ),
      ],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NoteEditorSnapshot) return false;
    if (title != other.title || checklist.length != other.checklist.length) {
      return false;
    }
    for (var i = 0; i < checklist.length; i++) {
      final a = checklist[i];
      final b = other.checklist[i];
      if (a.text != b.text || a.done != b.done) return false;
    }
    if (segments.length != other.segments.length) return false;
    for (var i = 0; i < segments.length; i++) {
      final a = segments[i];
      final b = other.segments[i];
      if (a.isProse != b.isProse) return false;
      if (a.isProse) {
        if (a.text != b.text) return false;
      } else {
        final at = a.table!;
        final bt = b.table!;
        if (at.columns != bt.columns || at.rows.length != bt.rows.length) {
          return false;
        }
        for (var r = 0; r < at.rows.length; r++) {
          if (at.rows[r].length != bt.rows[r].length) return false;
          for (var c = 0; c < at.rows[r].length; c++) {
            if (at.rows[r][c] != bt.rows[r][c]) return false;
          }
        }
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(title, checklist.length, segments.length);
}
