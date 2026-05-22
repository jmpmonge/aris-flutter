import 'note_editor_blocks.dart';

/// Hueco vertical entre bloques del cuerpo de la nota amplia (v0.49.43).
///
/// Única fuente de verdad para transiciones entre bloques. El render aplica
/// [gapBetween] **después** del bloque anterior vía `_gapAfterBlock`.
/// No aplica a saltos de línea dentro de un mismo bloque prose.
abstract final class NoteBodyBlockSpacing {
  NoteBodyBlockSpacing._();

  static const double proseToTable = 2;
  static const double tableToProse = 8;
  static const double proseToChecklist = 2;
  static const double checklistToProse = 8;
  static const double tableToChecklist = 8;
  static const double checklistToTable = 8;
  static const double tableToTable = 8;
  static const double checklistToChecklist = 4;
  /// Solo bloques prose independientes (p. ej. tras insertar tabla/checklist).
  static const double proseToProse = 0;

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
