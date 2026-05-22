import 'note_checklist_line.dart';
import 'note_prose_block_field.dart';
import 'note_table_block_editor.dart';

enum NoteEditorBlockKind { prose, table, checklist }

/// Bloque de contenido ordenado en el editor de nota (v0.49.42–v0.49.43).
final class NoteEditorBlock {
  NoteEditorBlock.prose(this.prose)
      : table = null,
        checklist = null,
        kind = NoteEditorBlockKind.prose;

  NoteEditorBlock.table(this.table)
      : prose = null,
        checklist = null,
        kind = NoteEditorBlockKind.table;

  NoteEditorBlock.checklist(this.checklist)
      : prose = null,
        table = null,
        kind = NoteEditorBlockKind.checklist;

  final NoteEditorBlockKind kind;
  final NoteProseBlockState? prose;
  final NoteTableBlockState? table;
  final NoteChecklistLineState? checklist;

  bool get isProse => kind == NoteEditorBlockKind.prose;
  bool get isTable => kind == NoteEditorBlockKind.table;
  bool get isChecklist => kind == NoteEditorBlockKind.checklist;
}
