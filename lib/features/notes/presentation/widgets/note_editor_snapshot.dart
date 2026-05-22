import 'note_body_format.dart';

/// Instantánea del contenido editable de la nota amplia (deshacer / rehacer).
final class NoteEditorSnapshot {
  const NoteEditorSnapshot({
    required this.title,
    required this.entries,
  });

  final String title;
  final List<NoteOrderedEntry> entries;

  static NoteEditorSnapshot fromDocument({
    required String title,
    required List<NoteOrderedEntry> entries,
  }) {
    return NoteEditorSnapshot(
      title: title,
      entries: [
        for (final entry in entries)
          if (entry.isChecklist)
            NoteOrderedEntry.checklist(
              NoteChecklistItem(
                text: entry.checklist!.text,
                done: entry.checklist!.done,
              ),
            )
          else if (entry.isProse)
            NoteOrderedEntry.prose(entry.proseText!)
          else
            NoteOrderedEntry.table(
              NoteTableBlock(
                columns: entry.table!.columns,
                rows: [
                  for (final row in entry.table!.rows)
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
    if (title != other.title || entries.length != other.entries.length) {
      return false;
    }
    for (var i = 0; i < entries.length; i++) {
      final a = entries[i];
      final b = other.entries[i];
      if (a.isChecklist != b.isChecklist ||
          a.isProse != b.isProse ||
          a.isTable != b.isTable) {
        return false;
      }
      if (a.isChecklist) {
        if (a.checklist!.text != b.checklist!.text ||
            a.checklist!.done != b.checklist!.done) {
          return false;
        }
      } else if (a.isProse) {
        if (a.proseText != b.proseText) return false;
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
  int get hashCode => Object.hash(title, entries.length);
}
