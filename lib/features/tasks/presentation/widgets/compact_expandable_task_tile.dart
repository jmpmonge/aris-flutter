import 'package:flutter/material.dart';

import '../../../../core/models/task_model.dart';
import '../../../../core/models/task_ui_buckets.dart';
import '../../../../theme/app_spacing.dart';

class CompactExpandableTaskTile extends StatefulWidget {
  const CompactExpandableTaskTile({
    super.key,
    required this.task,
    required this.section,
    required this.busy,
    required this.onCheckboxChanged,
  });

  final TaskModel task;
  final TaskBucketSection section;
  final bool busy;
  final ValueChanged<bool?> onCheckboxChanged;

  @override
  State<CompactExpandableTaskTile> createState() =>
      _CompactExpandableTaskTileState();
}

class _CompactExpandableTaskTileState extends State<CompactExpandableTaskTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final now = DateTime.now();
    final meta = TaskCompactFormat.compactMetaLine(
      widget.task,
      widget.section,
      now,
    );
    final strike = widget.task.completed;
    final high = TaskCompactFormat.priorityHigh(widget.task);

    final titleStyle = tt.bodyMedium?.copyWith(
      decoration: strike ? TextDecoration.lineThrough : null,
      color: strike
          ? scheme.onSurfaceVariant.withValues(alpha: 0.7)
          : scheme.onSurface,
      height: 1.25,
      fontWeight: FontWeight.w600,
    );

    final metaStyle = tt.bodySmall?.copyWith(
      color: strike
          ? scheme.onSurfaceVariant.withValues(alpha: 0.48)
          : scheme.onSurfaceVariant.withValues(alpha: 0.78),
      height: 1.25,
    );

    final desc = (widget.task.description ?? '').trim();
    final hasDesc = desc.isNotEmpty;
    final tagsLabel = widget.task.tags.where((x) => x.trim().isNotEmpty).join(' · ');
    final hasTags = tagsLabel.isNotEmpty;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: Theme.of(context).cardTheme.elevation ?? 2,
      shadowColor: Theme.of(context).cardTheme.shadowColor,
      shape: Theme.of(context).cardTheme.shape,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xs,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: AppSpacing.minTouchTarget * 0.85,
              child: Checkbox(
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: widget.task.completed,
                onChanged: widget.busy ? null : widget.onCheckboxChanged,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: () => setState(() => _open = !_open),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd * 0.5),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 2, AppSpacing.sm, AppSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.task.title,
                                  style: titleStyle,
                                  maxLines: _open ? 6 : 2,
                                  overflow:
                                      _open ? TextOverflow.visible : TextOverflow.ellipsis,
                                ),
                              ),
                              if (high) ...[
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  '\u26A0',
                                  style: tt.titleSmall?.copyWith(
                                    height: 1,
                                    color: scheme.secondary.withValues(
                                      alpha: 0.92,
                                    ),
                                  ),
                                  semanticsLabel: 'Prioridad alta',
                                ),
                              ],
                            ],
                          ),
                          if (meta.isNotEmpty)
                            Padding(
                              padding:
                                  EdgeInsets.only(top: AppSpacing.xxs),
                              child: Text(meta, style: metaStyle),
                            ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topLeft,
                    child: _open
                        ? Padding(
                            padding:
                                EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (hasDesc)
                                  Padding(
                                    padding:
                                        EdgeInsets.only(right: AppSpacing.sm),
                                    child: Text(
                                      desc,
                                      style: tt.bodyMedium?.copyWith(
                                        height: 1.35,
                                        color:
                                            scheme.onSurfaceVariant.withValues(
                                          alpha: 0.94,
                                        ),
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                if (hasTags)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: hasDesc ? AppSpacing.sm : 0,
                                      right: AppSpacing.sm,
                                    ),
                                    child: Text(
                                      tagsLabel,
                                      style: tt.labelSmall?.copyWith(
                                        color: scheme.outline.withValues(alpha: 0.95),
                                        height: 1.3,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
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
