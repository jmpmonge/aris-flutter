import 'note_editor_blocks.dart';

/// Hueco vertical entre bloques del cuerpo de la nota amplia (v0.49.43).
///
/// Única fuente de verdad para transiciones entre bloques. El render en
/// [ManualNoteCanvasSheet] solo aplica estos valores vía `_blockSeparator`;
/// no hay gaps simétricos ni constantes duplicadas en [AppSpacing].
abstract final class NoteBodyBlockSpacing {
  NoteBodyBlockSpacing._();

  static const double proseToTable = 2;
  static const double tableToProse = 8;
  static const double proseToChecklist = 2;
  static const double checklistToProse = 8;
  static const double proseToProse = 6;
  static const double checklistToChecklist = 4;
  static const double tableToChecklist = 8;
  static const double checklistToTable = 8;
  static const double tableToTable = 8;

  /// Separación según bloque anterior → bloque actual (asimétrico por diseño).
  static double gapBetween(
    NoteEditorBlockKind previous,
    NoteEditorBlockKind current,
  ) =>
      spacingBetweenBlocks(previous, current);

  /// Alias explícito para el render de la columna de bloques.
  static double spacingBetweenBlocks(
    NoteEditorBlockKind previous,
    NoteEditorBlockKind current,
  ) {
    switch ((previous, current)) {
      case (NoteEditorBlockKind.prose, NoteEditorBlockKind.table):
        return proseToTable;
      case (NoteEditorBlockKind.table, NoteEditorBlockKind.prose):
        return tableToProse;
      case (NoteEditorBlockKind.prose, NoteEditorBlockKind.checklist):
        return proseToChecklist;
      case (NoteEditorBlockKind.checklist, NoteEditorBlockKind.prose):
        return checklistToProse;
      case (NoteEditorBlockKind.prose, NoteEditorBlockKind.prose):
        return proseToProse;
      case (NoteEditorBlockKind.checklist, NoteEditorBlockKind.table):
        return checklistToTable;
      case (NoteEditorBlockKind.table, NoteEditorBlockKind.checklist):
        return tableToChecklist;
      case (NoteEditorBlockKind.table, NoteEditorBlockKind.table):
        return tableToTable;
      case (NoteEditorBlockKind.checklist, NoteEditorBlockKind.checklist):
        return checklistToChecklist;
    }
  }
}
