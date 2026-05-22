import 'package:flutter/material.dart';

import '../../../../core/models/task_model.dart';
import '../../../../core/models/task_ui_buckets.dart';
import '../../../../theme/app_colors.dart';

/// Cuerpo expandido de una tarea en la lista (v0.49.44 paso 4).
class TaskExpandedCard extends StatefulWidget {
  const TaskExpandedCard({
    super.key,
    required this.task,
    required this.section,
    required this.onEdit,
    this.onDelete,
  });

  final TaskModel task;
  final TaskBucketSection section;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  State<TaskExpandedCard> createState() => _TaskExpandedCardState();
}

class _TaskExpandedCardState extends State<TaskExpandedCard> {
  bool _descriptionExpanded = false;

  static const int _descriptionMaxLines = 3;
  static const double _sectionGap = AppColors.taskListExpandedSectionGap;

  @override
  void didUpdateWidget(TaskExpandedCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id) {
      _descriptionExpanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateChip = TaskCompactFormat.expandedDateChip(
      widget.task,
      widget.section,
      now,
    );
    final timeChip = (widget.task.timeText ?? '').trim();
    final priorityChip = TaskCompactFormat.expandedPriorityChip(widget.task);
    final desc = TaskModel.expandedDescription(widget.task);

    final chips = <Widget>[
      if (dateChip != null && dateChip.isNotEmpty)
        _MetaChip(
          icon: Icons.calendar_today_outlined,
          label: dateChip,
        ),
      if (timeChip.isNotEmpty)
        _MetaChip(
          icon: Icons.access_time_rounded,
          label: timeChip,
        ),
      if (priorityChip != null)
        _MetaChip(
          icon: Icons.flag_outlined,
          label: priorityChip,
        ),
    ];

    final hasBody = chips.isNotEmpty || desc.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (chips.isNotEmpty) ...[
          SizedBox(height: _sectionGap),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: chips,
          ),
        ],
        if (desc.isNotEmpty) ...[
          SizedBox(height: chips.isEmpty ? _sectionGap : _sectionGap),
          _DescriptionBlock(
            key: ValueKey('desc-${widget.task.id}-$_descriptionExpanded'),
            text: desc,
            expanded: _descriptionExpanded,
            maxLines: _descriptionMaxLines,
            onToggle: () =>
                setState(() => _descriptionExpanded = !_descriptionExpanded),
          ),
        ],
        if (hasBody) SizedBox(height: _sectionGap),
        Divider(
          height: 1,
          thickness: 1,
          color: AppColors.taskListBorderNormal.withValues(alpha: 0.85),
        ),
        SizedBox(height: _sectionGap - 2),
        Row(
          children: [
            _ActionLink(
              label: 'Editar',
              onTap: widget.onEdit,
            ),
            const Spacer(),
            if (widget.onDelete != null)
              _ActionLink(
                label: 'Borrar',
                onTap: widget.onDelete!,
                destructive: true,
              ),
          ],
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.taskListChipFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.taskListBorderNormal.withValues(alpha: 0.9),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: AppColors.taskListChipIcon,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                height: 1.15,
                fontWeight: FontWeight.w500,
                color: AppColors.taskListChipText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionBlock extends StatelessWidget {
  const _DescriptionBlock({
    super.key,
    required this.text,
    required this.expanded,
    required this.maxLines,
    required this.onToggle,
  });

  final String text;
  final bool expanded;
  final int maxLines;
  final VoidCallback onToggle;

  static bool _needsExpandLink(
    String text,
    double maxWidth,
    TextStyle style,
    int maxLines,
    TextDirection direction,
  ) {
    if (text.split('\n').length > maxLines) return true;
    final span = TextSpan(text: text, style: style);
    final collapsed = TextPainter(
      text: span,
      maxLines: maxLines,
      textDirection: direction,
    )..layout(maxWidth: maxWidth);
    if (collapsed.didExceedMaxLines) return true;
    final full = TextPainter(
      text: span,
      textDirection: direction,
    )..layout(maxWidth: maxWidth);
    return full.height > collapsed.height + 1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const style = TextStyle(
          fontSize: 14,
          height: 1.38,
          fontWeight: FontWeight.w400,
          color: AppColors.taskListTextSecondary,
        );
        final direction = Directionality.of(context);
        final maxW = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 96;
        final canExpand = _needsExpandLink(
          text,
          maxW,
          style,
          maxLines,
          direction,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: style,
              maxLines: expanded ? null : maxLines,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (canExpand)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: GestureDetector(
                  onTap: onToggle,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    expanded ? 'Ver menos' : 'Ver más',
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                      color: AppColors.taskListAccent,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ActionLink extends StatelessWidget {
  const _ActionLink({
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: destructive
                  ? AppColors.taskListDestructive.withValues(alpha: 0.78)
                  : AppColors.taskListAccent,
            ),
          ),
        ),
      ),
    );
  }
}
