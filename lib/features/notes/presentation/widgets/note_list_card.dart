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
  static const double _pinSize = 15;

  static const TextStyle _titleStyle = TextStyle(
    fontSize: 17,
    height: 1.22,
    fontWeight: FontWeight.w600,
    color: AppColors.noteWideTextPrimary,
  );

  static const TextStyle _previewStyle = TextStyle(
    fontSize: 15,
    height: 1.32,
    fontWeight: FontWeight.w400,
    color: AppColors.noteWideTextSecondary,
  );

  static const TextStyle _timeStyle = TextStyle(
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: AppColors.noteWideTextMuted,
  );

  static const double _metaFontSize = 13;
  static const double _metaIconSize = 14;
  static const int _maxVisibleTags = 2;

  static const TextStyle _metaStyle = TextStyle(
    fontSize: _metaFontSize,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: AppColors.noteWideTextMuted,
  );

  static const TextStyle _tagStyle = TextStyle(
    fontSize: _metaFontSize,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: AppColors.noteListTagTint,
  );

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.fromLTRB(12, 9, 8, 9),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            note.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _titleStyle,
                          ),
                        ),
                        if (note.pinned) ...[
                          const SizedBox(width: 5),
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.push_pin_rounded,
                              size: _pinSize,
                              color: AppColors.noteListPinTint,
                            ),
                          ),
                        ],
                        if (note.listTimeLabel != null &&
                            note.listTimeLabel!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(note.listTimeLabel!, style: _timeStyle),
                        ],
                      ],
                    ),
                    if (note.body.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        note.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _previewStyle,
                      ),
                    ],
                    if (note.hasListMetadataRow) ...[
                      const SizedBox(height: 4),
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
      runSpacing: 2,
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
