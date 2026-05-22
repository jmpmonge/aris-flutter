/// Formato de cuerpo de nota: checklist, segmentos prosa/tabla (v0.49.42).
abstract final class NoteBodyFormat {
  NoteBodyFormat._();

  static const String pendingPrefix = '○ ';
  static const String donePrefix = '✓ ';
  static const String tableStartPrefix = '[TABLE cols=';
  static const String tableEndMarker = '[/TABLE]';
  static const String _pipeEscape = '｜';

  static NoteBodyDocument parse(String raw) {
    final checklist = <NoteChecklistItem>[];
    final segments = <NoteBodySegment>[];
    final proseBuffer = <String>[];

    void flushProse() {
      if (proseBuffer.isEmpty) return;
      segments.add(NoteBodySegment.prose(proseBuffer.join('\n')));
      proseBuffer.clear();
    }

    final lines = raw.split('\n');
    var i = 0;
    while (i < lines.length) {
      final line = lines[i];
      if (line.startsWith(tableStartPrefix) && line.endsWith(']')) {
        flushProse();
        final cols = _parseTableCols(line);
        i++;
        final rows = <List<String>>[];
        while (i < lines.length && lines[i] != tableEndMarker) {
          rows.add(_parseTableRow(lines[i], cols));
          i++;
        }
        if (i < lines.length && lines[i] == tableEndMarker) {
          i++;
        }
        segments.add(NoteBodySegment.table(NoteTableBlock(columns: cols, rows: rows)));
        continue;
      }

      if (line.startsWith(donePrefix)) {
        flushProse();
        final t = line.substring(donePrefix.length).trim();
        if (t.isNotEmpty) {
          checklist.add(NoteChecklistItem(text: t, done: true));
        }
      } else if (line.startsWith(pendingPrefix)) {
        flushProse();
        final t = line.substring(pendingPrefix.length).trim();
        if (t.isNotEmpty) {
          checklist.add(NoteChecklistItem(text: t, done: false));
        }
      } else {
        proseBuffer.add(line);
      }
      i++;
    }
    flushProse();

    return NoteBodyDocument(
      checklist: checklist,
      segments: segments,
    );
  }

  static String merge({
    required List<NoteChecklistItem> checklist,
    required List<NoteBodySegment> segments,
  }) {
    final parts = <String>[
      for (final item in checklist)
        if (item.text.trim().isNotEmpty)
          '${item.done ? donePrefix : pendingPrefix}${item.text.trim()}',
      for (final segment in segments)
        if (segment.isProse)
          segment.text!.trim()
        else
          _serializeTable(segment.table!),
    ];
    return parts.where((p) => p.isNotEmpty).join('\n');
  }

  static int _parseTableCols(String header) {
    final inner = header.substring(tableStartPrefix.length, header.length - 1);
    final cols = int.tryParse(inner);
    return cols != null && cols > 0 ? cols : 2;
  }

  static List<String> _parseTableRow(String line, int cols) {
    final cells = line.split('|').map(_unescapeCell).toList();
    while (cells.length < cols) {
      cells.add('');
    }
    if (cells.length > cols) {
      return cells.sublist(0, cols);
    }
    return cells;
  }

  static String _serializeTable(NoteTableBlock table) {
    final buf = StringBuffer('$tableStartPrefix${table.columns}]\n');
    for (final row in table.rows) {
      buf.writeln(
        List.generate(
          table.columns,
          (c) => _escapeCell(c < row.length ? row[c] : ''),
        ).join('|'),
      );
    }
    buf.write(tableEndMarker);
    return buf.toString();
  }

  static String _escapeCell(String value) =>
      value.replaceAll('|', _pipeEscape);

  static String _unescapeCell(String value) =>
      value.replaceAll(_pipeEscape, '|');
}

class NoteBodyDocument {
  const NoteBodyDocument({
    required this.checklist,
    required this.segments,
  });

  final List<NoteChecklistItem> checklist;
  final List<NoteBodySegment> segments;
}

/// Segmento ordenado de prosa o tabla en el cuerpo.
class NoteBodySegment {
  const NoteBodySegment.prose(this.text) : table = null;

  const NoteBodySegment.table(this.table) : text = null;

  final String? text;
  final NoteTableBlock? table;

  bool get isProse => text != null;
  bool get isTable => table != null;
}

/// Bloque de tabla simple (v0.49.42).
class NoteTableBlock {
  NoteTableBlock({
    required this.columns,
    required List<List<String>> rows,
  }) : rows = rows
            .map((r) => List<String>.from(r))
            .toList(growable: false);

  final int columns;
  final List<List<String>> rows;

  factory NoteTableBlock.empty({int columns = 2, int rowCount = 3}) {
    return NoteTableBlock(
      columns: columns,
      rows: List.generate(
        rowCount,
        (_) => List.filled(columns, ''),
      ),
    );
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
