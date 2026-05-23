import 'package:flutter/material.dart';

import '../../../../core/models/note_model.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/aris_list_palette.dart';
import '../manual_note_canvas_sheet.dart';
import 'note_expanded_details_content.dart';

/// Ficha flotante de detalle de nota — Home y listado Notas (v0.49.96).
abstract final class NoteDetailSheet {
  NoteDetailSheet._();

  static Future<void> show(BuildContext context, NoteModel note) {
    final scheme = Theme.of(context).colorScheme;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: context.arisList.cardFill,
      barrierColor: scheme.scrim.withValues(alpha: 0.45),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (ctx) => _NoteDetailSheetBody(note: note),
    );
  }
}

class _NoteDetailSheetBody extends StatelessWidget {
  const _NoteDetailSheetBody({required this.note});

  final NoteModel note;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.md + bottomInset,
      ),
      child: NoteExpandedDetailsContent(
        note: note,
        onEdit: () {
          Navigator.of(context).pop();
          ManualNoteCanvasSheet.openExisting(context, note);
        },
      ),
    );
  }
}
