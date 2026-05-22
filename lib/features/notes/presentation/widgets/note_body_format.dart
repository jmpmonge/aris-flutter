/// Formato de cuerpo de nota: checklist `○` / `✓` + prosa libre (v0.49.41).
abstract final class NoteBodyFormat {
  NoteBodyFormat._();

  static const String pendingPrefix = '○ ';
  static const String donePrefix = '✓ ';

  static ({List<NoteChecklistItem> checklist, String prose}) parse(String raw) {
    final checklist = <NoteChecklistItem>[];
    final proseLines = <String>[];
    for (final line in raw.split('\n')) {
      if (line.startsWith(donePrefix)) {
        final t = line.substring(donePrefix.length).trim();
        if (t.isNotEmpty) {
          checklist.add(NoteChecklistItem(text: t, done: true));
        }
      } else if (line.startsWith(pendingPrefix)) {
        final t = line.substring(pendingPrefix.length).trim();
        if (t.isNotEmpty) {
          checklist.add(NoteChecklistItem(text: t, done: false));
        }
      } else {
        proseLines.add(line);
      }
    }
    return (checklist: checklist, prose: proseLines.join('\n'));
  }

  static String merge({
    required List<NoteChecklistItem> checklist,
    required String prose,
  }) {
    final parts = <String>[
      for (final item in checklist)
        if (item.text.trim().isNotEmpty)
          '${item.done ? donePrefix : pendingPrefix}${item.text.trim()}',
      if (prose.trim().isNotEmpty) prose.trim(),
    ];
    return parts.join('\n');
  }
}

/// Ítem de checklist interno de una nota (no es tarea del sistema).
class NoteChecklistItem {
  const NoteChecklistItem({required this.text, this.done = false});

  final String text;
  final bool done;

  NoteChecklistItem copyWith({String? text, bool? done}) {
    return NoteChecklistItem(
      text: text ?? this.text,
      done: done ?? this.done,
    );
  }
}
