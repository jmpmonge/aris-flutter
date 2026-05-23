import 'package:flutter/material.dart';

import '../../../../core/models/task_model.dart';
import '../../../../core/models/task_ui_buckets.dart';
import '../../../../theme/aris_list_palette.dart';
import '../../../../theme/app_spacing.dart';

/// Fila compacta de tarea — tap abre ficha inferior (v0.49.98).
class CompactExpandableTaskTile extends StatelessWidget {
  const CompactExpandableTaskTile({
    super.key,
    required this.task,
    required this.section,
    required this.busy,
    required this.onOpenDetail,
    required this.onCheckboxChanged,
  });

  final TaskModel task;
  final TaskBucketSection section;
  final bool busy;
  final VoidCallback onOpenDetail;
  final ValueChanged<bool?> onCheckboxChanged;

  static const double _checkSlot = 22;
  static const double _checkTextGap = 10;
  static const double _cardRadius = 14;
  static const double _closedPadH = AppSpacing.md;
  static const double _closedPadV = 12;

  @override
  Widget build(BuildContext context) {
    final completed = task.completed;
    final isCompletedSection = section == TaskBucketSection.completed;
    final muted = completed || isCompletedSection;

    final titleStyle = TextStyle(
      fontSize: 15,
      height: 1.22,
      fontWeight: FontWeight.w600,
      color: muted
          ? context.arisList.textSecondary.withValues(alpha: 0.72)
          : context.arisList.textPrimary,
      decoration: muted ? TextDecoration.lineThrough : null,
      decorationColor: context.arisList.textMuted,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.arisList.cardFill.withValues(
          alpha: muted ? 0.72 : 1,
        ),
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: context.arisList.borderNormal),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          _closedPadH - 4,
          _closedPadV - 2,
          _closedPadH - 2,
          _closedPadV - 2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: busy ? null : () => onCheckboxChanged(!completed),
                child: SizedBox(
                  width: _checkSlot + 8,
                  height: _checkSlot + 8,
                  child: Align(
                    child: Checkbox(
                      shape: const CircleBorder(),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      activeColor: context.arisList.completedCheck,
                      checkColor: context.arisList.canvas,
                      side: BorderSide(
                        color: muted
                            ? context.arisList.accent.withValues(alpha: 0.55)
                            : context.arisList.textMuted
                                .withValues(alpha: 0.65),
                        width: 1.4,
                      ),
                      value: completed,
                      onChanged: busy ? null : onCheckboxChanged,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: _checkTextGap - 4),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  onTap: onOpenDetail,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      task.title,
                      style: titleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
