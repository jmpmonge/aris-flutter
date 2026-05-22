import 'note_editor_blocks.dart';

/// Hueco visual entre bloques del cuerpo de la nota amplia (v0.49.43).
/// Única fuente de verdad: el render solo usa [gapBetween] vía separador en columna.
abstract final class NoteBodyBlockSpacing {
  NoteBodyBlockSpacing._();

  static double gapBetween(
    NoteEditorBlockKind previous,
    NoteEditorBlockKind current,
  ) {
    switch ((previous, current)) {
      case (NoteEditorBlockKind.prose, NoteEditorBlockKind.table):
        return 4;
      case (NoteEditorBlockKind.table, NoteEditorBlockKind.prose):
        return 10;
      case (NoteEditorBlockKind.prose, NoteEditorBlockKind.checklist):
        return 4;
      case (NoteEditorBlockKind.checklist, NoteEditorBlockKind.prose):
        return 10;
      case (NoteEditorBlockKind.prose, NoteEditorBlockKind.prose):
        return 6;
      case (NoteEditorBlockKind.checklist, NoteEditorBlockKind.table):
        return 8;
      case (NoteEditorBlockKind.table, NoteEditorBlockKind.checklist):
        return 8;
      case (NoteEditorBlockKind.table, NoteEditorBlockKind.table):
        return 8;
      case (NoteEditorBlockKind.checklist, NoteEditorBlockKind.checklist):
        return 2;
    }
  }
}
