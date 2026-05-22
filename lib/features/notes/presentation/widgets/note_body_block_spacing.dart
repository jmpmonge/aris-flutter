import 'note_editor_blocks.dart';

/// Hueco vertical entre bloques del cuerpo de la nota amplia (v0.49.43).
///
/// El render aplica [gapBetween] **después** del bloque anterior vía `_gapAfterBlock`.
/// Los saltos Intro dentro de un bloque prose se resuelven en [NoteProseBlockField].
abstract final class NoteBodyBlockSpacing {
  NoteBodyBlockSpacing._();

  static const double proseToTable = 4;
  static const double tableToProse = 10;
  static const double proseToChecklist = 4;
  static const double checklistToProse = 10;
  static const double tableToChecklist = 10;
  static const double checklistToTable = 10;
  static const double tableToTable = 10;
  static const double checklistToChecklist = 2;
  /// Bloques prose separados solo si existen por inserción de bloques.
  static const double proseToProse = 6;

  static double gapBetween(
    NoteEditorBlockKind previous,
    NoteEditorBlockKind current,
  ) =>
      spacingBetweenBlocks(previous, current);

  static double spacingBetweenBlocks(
    NoteEditorBlockKind previous,
    NoteEditorBlockKind current,
  ) {
    switch ((previous, current)) {
      case (NoteEditorBlockKind.prose, NoteEditorBlockKind.table):
        return NoteBodyBlockSpacing.proseToTable;
      case (NoteEditorBlockKind.table, NoteEditorBlockKind.prose):
        return NoteBodyBlockSpacing.tableToProse;
      case (NoteEditorBlockKind.prose, NoteEditorBlockKind.checklist):
        return NoteBodyBlockSpacing.proseToChecklist;
      case (NoteEditorBlockKind.checklist, NoteEditorBlockKind.prose):
        return NoteBodyBlockSpacing.checklistToProse;
      case (NoteEditorBlockKind.prose, NoteEditorBlockKind.prose):
        return NoteBodyBlockSpacing.proseToProse;
      case (NoteEditorBlockKind.checklist, NoteEditorBlockKind.table):
        return NoteBodyBlockSpacing.checklistToTable;
      case (NoteEditorBlockKind.table, NoteEditorBlockKind.checklist):
        return NoteBodyBlockSpacing.tableToChecklist;
      case (NoteEditorBlockKind.table, NoteEditorBlockKind.table):
        return NoteBodyBlockSpacing.tableToTable;
      case (NoteEditorBlockKind.checklist, NoteEditorBlockKind.checklist):
        return NoteBodyBlockSpacing.checklistToChecklist;
    }
  }
}
