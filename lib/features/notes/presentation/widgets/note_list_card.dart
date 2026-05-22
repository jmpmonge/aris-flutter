import 'package:flutter/material.dart';

import '../../../../core/models/note_model.dart';
import '../../../../theme/app_colors.dart';

/// Tarjeta ligera del listado de notas (v0.49.43).
class NoteListCard extends StatelessWidget {
  const NoteListCard({
    super.key,
    required this.note,
    required this.onTap,
    this.trailing,
  });

  final NoteModel note;
  final VoidCallback onTap;
  final Widget? trailing;

  static const double _radius = 14;
  static const double _pinSize = 14;
  static const double _metaIconSize = 13;
  static const int _maxVisibleTags = 2;

  static const TextStyle _metaStyle = TextStyle(
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: AppColors.noteWideTextMuted,
  );

  static const TextStyle _tagStyle = TextStyle(
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: AppColors.noteListTagTint,
  );

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final tags = note.listDisplayTags;
    final visibleTags = tags.take(_maxVisibleTags).toList();
    final extraTags = tags.length - visibleTags.length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_radius),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.noteListCardFill.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: AppColors.noteListCardBorder),
          ),
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            note.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                            ),
                          ),
                        ),
                        if (note.pinned) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.push_pin_rounded,
                            size: _pinSize,
                            color: AppColors.noteListPinTint,
                          ),
                        ],
                        if (note.listTimeLabel != null &&
                            note.listTimeLabel!.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(note.listTimeLabel!, style: _metaStyle),
                        ],
                      ],
                    ),
                    if (note.body.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        note.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall?.copyWith(
                          color: AppColors.noteWideTextSecondary,
                          height: 1.35,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                    if (note.hasListMetadataRow) ...[
                      const SizedBox(height: 5),
                      _MetadataRow(
                        note: note,
                        visibleTags: visibleTags,
                        extraTags: extraTags,
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    required this.note,
    required this.visibleTags,
    required this.extraTags,
  });

  final NoteModel note;
  final List<String> visibleTags;
  final int extraTags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 3,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (note.hasAttachments) ...[
          const Icon(
            Icons.attach_file_rounded,
            size: NoteListCard._metaIconSize,
            color: AppColors.noteWideTextMuted,
          ),
          Text(
            note.attachmentName ?? 'Adjunto',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: NoteListCard._metaStyle,
          ),
        ],
        for (final tag in visibleTags) Text(tag, style: NoteListCard._tagStyle),
        if (extraTags > 0)
          Text('+$extraTags', style: NoteListCard._tagStyle),
      ],
    );
  }
}
