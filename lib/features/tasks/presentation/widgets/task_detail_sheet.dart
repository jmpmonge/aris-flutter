import 'package:flutter/material.dart';

import '../../../../core/models/task_model.dart';
import '../../../../core/models/task_ui_buckets.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/aris_list_palette.dart';
import 'task_expanded_details_content.dart';

/// Ficha inferior compacta de tarea (v0.49.97).
abstract final class TaskDetailSheet {
  TaskDetailSheet._();

  static Future<void> show(
    BuildContext context, {
    required TaskModel task,
    required TaskBucketSection section,
    required VoidCallback onToggleComplete,
    required VoidCallback onEdit,
    VoidCallback? onDelete,
    bool busy = false,
  }) {
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
      builder: (ctx) => _TaskDetailSheetBody(
        task: task,
        section: section,
        onToggleComplete: () {
          Navigator.of(ctx).pop();
          onToggleComplete();
        },
        onEdit: () {
          Navigator.of(ctx).pop();
          onEdit();
        },
        onDelete: onDelete == null
            ? null
            : () {
                Navigator.of(ctx).pop();
                onDelete();
              },
        busy: busy,
      ),
    );
  }
}

class _TaskDetailSheetBody extends StatelessWidget {
  const _TaskDetailSheetBody({
    required this.task,
    required this.section,
    required this.onToggleComplete,
    required this.onEdit,
    this.onDelete,
    required this.busy,
  });

  final TaskModel task;
  final TaskBucketSection section;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xxs,
        AppSpacing.md,
        AppSpacing.sm + bottomInset,
      ),
      child: TaskExpandedDetailsContent(
        task: task,
        section: section,
        busy: busy,
        onToggleComplete: onToggleComplete,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }
}
