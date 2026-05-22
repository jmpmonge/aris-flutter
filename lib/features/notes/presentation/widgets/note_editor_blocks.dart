import 'note_prose_block_field.dart';
import 'note_table_block_editor.dart';

enum NoteEditorBlockKind { prose, table }

/// Bloque de contenido ordenado en el editor de nota (v0.49.42).
final class NoteEditorBlock {
  NoteEditorBlock.prose(this.prose)
      : table = null,
        kind = NoteEditorBlockKind.prose;

  NoteEditorBlock.table(this.table)
      : prose = null,
        kind = NoteEditorBlockKind.table;

  final NoteEditorBlockKind kind;
  final NoteProseBlockState? prose;
  final NoteTableBlockState? table;

  bool get isProse => kind == NoteEditorBlockKind.prose;
  bool get isTable => kind == NoteEditorBlockKind.table;
}
