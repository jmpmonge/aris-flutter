import 'package:flutter/material.dart';

import '../../../../core/models/task_model.dart';
import '../../../../core/models/task_ui_buckets.dart';
import '../../../../shared/widgets/premium_pressable.dart';
import '../../../../shared/widgets/smooth_card_expand.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import 'task_expanded_card.dart';

/// Tarjeta compacta de tarea con check y expansión inline (v0.49.44 paso 4).
class CompactExpandableTaskTile extends StatelessWidget {
  const CompactExpandableTaskTile({
    super.key,
    required this.task,
    required this.section,
    required this.isExpanded,
    required this.busy,
    required this.onToggleExpand,
    required this.onCheckboxChanged,
    required this.onEdit,
    this.onDelete,
  });

  final TaskModel task;
  final TaskBucketSection section;
  final bool isExpanded;
  final bool busy;
  final VoidCallback onToggleExpand;
  final ValueChanged<bool?> onCheckboxChanged;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

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
          ? AppColors.taskListTextSecondary.withValues(alpha: 0.72)
          : AppColors.taskListTextPrimary,
      decoration: muted ? TextDecoration.lineThrough : null,
      decorationColor: AppColors.taskListTextMuted,
    );

    final cardFill = isExpanded
        ? AppColors.taskListCardExpandedFill
        : AppColors.taskListCardFill;
    final borderColor = isExpanded
        ? AppColors.taskListBorderSelected
        : AppColors.taskListBorderNormal;

    final padH = isExpanded
        ? AppColors.taskListExpandedPadH
        : _closedPadH;
    final padV = isExpanded
        ? AppColors.taskListExpandedPadV
        : _closedPadV;

    return AnimatedContainer(
      duration: Duration(milliseconds: AppSpacing.cardExpandSizeMs),
      curve: isExpanded ? Curves.easeOutCubic : Curves.easeInOutCubic,
      decoration: BoxDecoration(
        color: cardFill.withValues(alpha: muted && !isExpanded ? 0.72 : 1),
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: borderColor, width: isExpanded ? 1.15 : 1),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          padH,
          padV,
          padH - 2,
          padV,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: _checkSlot,
              height: _checkSlot,
              child: Align(
                alignment: Alignment.center,
                child: Checkbox(
                  shape: const CircleBorder(),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  activeColor: AppColors.taskListCompletedCheck,
                  checkColor: AppColors.taskListCanvas,
                  side: BorderSide(
                    color: muted
                        ? AppColors.taskListAccent.withValues(alpha: 0.55)
                        : AppColors.taskListTextMuted.withValues(alpha: 0.65),
                    width: 1.4,
                  ),
                  value: completed,
                  onChanged: busy ? null : onCheckboxChanged,
                ),
              ),
            ),
            SizedBox(width: _checkTextGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PremiumPressable(
                    onTap: onToggleExpand,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 1,
                        bottom: 1,
                        right: 2,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: titleStyle,
                              maxLines: isExpanded ? 3 : 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          SmoothCardExpandChevron(
                            isExpanded: isExpanded,
                            color: AppColors.taskListTextMuted
                                .withValues(alpha: 0.82),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SmoothCardExpandReveal(
                    isExpanded: isExpanded,
                    child: TaskExpandedCard(
                      key: ValueKey('expanded-${task.id}'),
                      task: task,
                      section: section,
                      onEdit: onEdit,
                      onDelete: onDelete,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
