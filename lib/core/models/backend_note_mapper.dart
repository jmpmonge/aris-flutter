import 'note_model.dart';

/// Mapper desde `/notes`: `id`, `title`, `content`, timestamps opcionales.
abstract final class BackendNoteMapper {
  static NoteModel? tryParse(Map<String, dynamic> m) {
    try {
      final id = _trim(m['id']);
      final titleRaw = _trim(m['title']);
      final body = _body(m);

      if (body.isEmpty && titleRaw.isEmpty) return null;

      final title = titleRaw.isNotEmpty ? titleRaw : _firstWords(body);

      return NoteModel(
        id:
            id.isEmpty ? 'note_${identityHashCode(m)}' : id,
        title: title.isEmpty ? 'Nota' : title,
        body: body,
      );
    } on Object {
      return null;
    }
  }

  static List<NoteModel> parseSortedNewest(List<Map<String, dynamic>> raw) {
    final rows = [...raw];

    rows.sort((a, b) {
      final aa = BackendNoteMapper.tryParseTimestamp(a['created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bb =
          BackendNoteMapper.tryParseTimestamp(b['created_at']) ??
              DateTime.fromMillisecondsSinceEpoch(0);
      return bb.compareTo(aa);
    });

    final out = <NoteModel>[];
    for (final r in rows) {
      final n = BackendNoteMapper.tryParse(r);
      if (n != null) out.add(n);
    }
    return out;
  }

  static DateTime? tryParseTimestamp(Object? v) =>
      DateTime.tryParse(v?.toString() ?? '');

  static String _trim(Object? v) => v?.toString().trim() ?? '';

  static String _body(Map<String, dynamic> m) =>
      (_trim(m['content']).isEmpty ? _trim(m['text']) : _trim(m['content']));

  static String _firstWords(String s) {
    if (s.isEmpty) return 'Nota';
    final ln = s.split('\n').first.trim();
    if (ln.length <= 72) return ln;
    return '${ln.substring(0, 72)}…';
  }
}
