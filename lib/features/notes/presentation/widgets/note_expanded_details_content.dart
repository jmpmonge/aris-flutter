import 'package:flutter/material.dart';

import '../../../../core/models/note_model.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/aris_list_palette.dart';

/// Contenido de detalle de nota — título, cuerpo, metadatos y Editar (v0.49.96).
class NoteExpandedDetailsContent extends StatelessWidget {
  const NoteExpandedDetailsContent({
    super.key,
    required this.note,
    required this.onEdit,
  });

  final NoteModel note;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final list = context.arisList;
    final body = note.body.trim();
    final tags = note.listDisplayTags;
    final metaLines = <_NoteDetailLine>[
      if (note.listTimeLabel != null && note.listTimeLabel!.trim().isNotEmpty)
        _NoteDetailLine(
          icon: Icons.schedule_outlined,
          text: note.listTimeLabel!.trim(),
        ),
      if (note.showFolderInList && note.folderName != null)
        _NoteDetailLine(
          icon: Icons.folder_outlined,
          text: note.folderName!.trim(),
        ),
      if (note.hasAttachments)
        _NoteDetailLine(
          icon: Icons.attach_file_rounded,
          text: note.attachmentName?.trim().isNotEmpty == true
              ? note.attachmentName!.trim()
              : 'Adjunto',
        ),
      if (note.hasChecklist && note.checklistItemCount > 0)
        _NoteDetailLine(
          icon: Icons.checklist_rounded,
          text: '${note.checklistItemCount} elementos',
        ),
      if (tags.isNotEmpty)
        _NoteDetailLine(
          icon: Icons.sell_outlined,
          text: tags.join('  '),
        ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                note.pinned ? Icons.push_pin_rounded : Icons.note_alt_outlined,
                size: 18,
                color: list.accent,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                note.title,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.22,
                  fontWeight: FontWeight.w600,
                  color: list.textPrimary,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (body.isNotEmpty) ...[
          SizedBox(height: AppSpacing.calendarDayExpandedDetailTopGap),
          Text(
            body,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.38,
              fontWeight: FontWeight.w400,
              color: list.textSecondary,
            ),
          ),
        ],
        if (metaLines.isNotEmpty) ...[
          SizedBox(height: AppSpacing.calendarDayExpandedDetailTopGap),
          for (var i = 0; i < metaLines.length; i++) ...[
            if (i > 0)
              SizedBox(height: AppSpacing.calendarDayExpandedDetailRowGap),
            _NoteExpandedIconLine(
              icon: metaLines[i].icon,
              text: metaLines[i].text,
            ),
          ],
        ],
        SizedBox(height: AppSpacing.calendarDayExpandedEditTopGap),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onEdit,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: list.accent,
            ),
            child: const Text(
              'Editar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NoteDetailLine {
  const _NoteDetailLine({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

class _NoteExpandedIconLine extends StatelessWidget {
  const _NoteExpandedIconLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            icon,
            size: 15,
            color: context.arisList.textMuted.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.28,
              fontWeight: FontWeight.w400,
              color: context.arisList.textSecondary,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
