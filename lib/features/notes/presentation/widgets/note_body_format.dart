/// Formato de cuerpo de nota: líneas `○ …` como checklist (v0.49.41).
abstract final class NoteBodyFormat {
  NoteBodyFormat._();

  static const String checklistPrefix = '○ ';

  static ({List<String> checklist, String prose}) parse(String raw) {
    final checklist = <String>[];
    final proseLines = <String>[];
    for (final line in raw.split('\n')) {
      if (line.startsWith(checklistPrefix)) {
        final t = line.substring(checklistPrefix.length).trim();
        if (t.isNotEmpty) checklist.add(t);
      } else {
        proseLines.add(line);
      }
    }
    return (checklist: checklist, prose: proseLines.join('\n'));
  }

  static String merge({
    required List<String> checklist,
    required String prose,
  }) {
    final parts = <String>[
      for (final item in checklist) '$checklistPrefix$item',
      if (prose.trim().isNotEmpty) prose.trim(),
    ];
    return parts.join('\n');
  }
}
