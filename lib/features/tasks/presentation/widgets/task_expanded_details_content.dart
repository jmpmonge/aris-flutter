import 'package:flutter/material.dart';

import '../../../../core/models/task_model.dart';
import '../../../../core/models/task_ui_buckets.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/aris_list_palette.dart';

/// Contenido compacto de detalle de tarea para bottom sheet (v0.49.97).
class TaskExpandedDetailsContent extends StatelessWidget {
  const TaskExpandedDetailsContent({
    super.key,
    required this.task,
    required this.section,
    required this.onToggleComplete,
    required this.onEdit,
    this.onDelete,
    this.busy = false,
  });

  final TaskModel task;
  final TaskBucketSection section;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final list = context.arisList;
    final completed = task.completed;
    final now = DateTime.now();
    final dateChip = TaskCompactFormat.expandedDateChip(task, section, now);
    final timeChip = (task.timeText ?? '').trim();
    final priorityChip = TaskCompactFormat.expandedPriorityChip(task);
    final desc = TaskModel.expandedDescription(task);
    final tags = task.tags.where((t) => t.trim().isNotEmpty).toList();

    final metaLines = <_TaskDetailLine>[
      _TaskDetailLine(
        icon: completed
            ? Icons.check_circle_outline_rounded
            : Icons.radio_button_unchecked_rounded,
        text: completed ? 'Completada' : 'Pendiente',
      ),
      _TaskDetailLine(
        icon: Icons.view_day_outlined,
        text: section.uiLabel,
      ),
      if (dateChip != null && dateChip.isNotEmpty)
        _TaskDetailLine(icon: Icons.calendar_today_outlined, text: dateChip),
      if (timeChip.isNotEmpty)
        _TaskDetailLine(icon: Icons.access_time_rounded, text: timeChip),
      if (priorityChip != null)
        _TaskDetailLine(icon: Icons.flag_outlined, text: priorityChip),
      if (tags.isNotEmpty)
        _TaskDetailLine(icon: Icons.sell_outlined, text: tags.join('  ')),
    ];

    final completeLabel =
        completed ? 'Marcar como pendiente' : 'Completar';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          task.title,
          style: TextStyle(
            fontSize: 16,
            height: 1.22,
            fontWeight: FontWeight.w600,
            color: completed
                ? list.textSecondary.withValues(alpha: 0.78)
                : list.textPrimary,
            decoration: completed ? TextDecoration.lineThrough : null,
            decorationColor: list.textMuted,
          ),
        ),
        if (metaLines.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          for (var i = 0; i < metaLines.length; i++) ...[
            if (i > 0) const SizedBox(height: 4),
            _TaskDetailIconLine(
              icon: metaLines[i].icon,
              text: metaLines[i].text,
            ),
          ],
        ],
        if (desc.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            desc,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.38,
              fontWeight: FontWeight.w400,
              color: list.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        _TaskSheetAction(
          label: completeLabel,
          onPressed: busy ? null : onToggleComplete,
          foregroundColor: list.accent,
        ),
        _TaskSheetAction(
          label: 'Editar',
          onPressed: onEdit,
          foregroundColor: list.accent,
        ),
        if (onDelete != null)
          _TaskSheetAction(
            label: 'Eliminar',
            onPressed: onDelete,
            foregroundColor: list.destructive.withValues(alpha: 0.85),
          ),
      ],
    );
  }
}

class _TaskDetailLine {
  const _TaskDetailLine({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

class _TaskDetailIconLine extends StatelessWidget {
  const _TaskDetailIconLine({
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
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _TaskSheetAction extends StatelessWidget {
  const _TaskSheetAction({
    required this.label,
    required this.onPressed,
    required this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: foregroundColor,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
