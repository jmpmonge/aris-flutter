import 'package:flutter/material.dart';

import '../../../../core/models/task_model.dart';
import '../../../../core/models/task_ui_buckets.dart';
import '../../../../theme/app_spacing.dart';

class CompactExpandableTaskTile extends StatefulWidget {
  const CompactExpandableTaskTile({
    super.key,
    required this.task,
    required this.section,
    this.initiallyExpanded = false,
    required this.busy,
    required this.onCheckboxChanged,
    this.onDelete,
  });

  final TaskModel task;
  final TaskBucketSection section;

  /// Desde Home: abrir detalle inline de la tarea seleccionada.
  final bool initiallyExpanded;
  final bool busy;
  final ValueChanged<bool?> onCheckboxChanged;

  /// Si no es null, se muestra un menú con «Eliminar».
  final VoidCallback? onDelete;

  @override
  State<CompactExpandableTaskTile> createState() =>
      _CompactExpandableTaskTileState();
}

class _CompactExpandableTaskTileState extends State<CompactExpandableTaskTile> {
  late bool _open;

  @override
  void initState() {
    super.initState();
    _open = widget.initiallyExpanded;
  }

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

    void toggleExpanded() => setState(() => _open = !_open);

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
                shape: const CircleBorder(),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: widget.task.completed,
                onChanged: widget.busy ? null : widget.onCheckboxChanged,
              ),
            ),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: toggleExpanded,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd * 0.5),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      0,
                      2,
                      AppSpacing.sm,
                      AppSpacing.sm,
                    ),
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
                                overflow: _open
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                              ),
                            ),
                            if (high) ...[
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                '\u26A0',
                                style: tt.titleSmall?.copyWith(
                                  height: 1,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFFD97706),
                                ),
                                semanticsLabel: 'Prioridad alta',
                              ),
                            ],
                            if (widget.onDelete != null)
                              PopupMenuButton<String>(
                                tooltip: 'Más opciones',
                                enabled: !widget.busy,
                                padding: EdgeInsets.zero,
                                onSelected: (v) {
                                  if (v == 'delete') widget.onDelete?.call();
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Eliminar'),
                                  ),
                                ],
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(left: AppSpacing.xs),
                                  child: Icon(
                                    Icons.more_vert_rounded,
                                    size: 18,
                                    color: scheme.onSurfaceVariant
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (meta.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: AppSpacing.xxs),
                            child: Text(meta, style: metaStyle),
                          ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          alignment: Alignment.topLeft,
                          child: _open
                              ? Padding(
                                  padding: EdgeInsets.only(
                                    top: AppSpacing.sm,
                                    bottom: AppSpacing.xs,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      if (hasDesc)
                                        Text(
                                          desc,
                                          style: tt.bodyMedium?.copyWith(
                                            height: 1.35,
                                            color: scheme.onSurfaceVariant
                                                .withValues(alpha: 0.94),
                                          ),
                                        ),
                                      if (hasTags)
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: hasDesc ? AppSpacing.sm : 0,
                                          ),
                                          child: Text(
                                            tagsLabel,
                                            style: tt.labelSmall?.copyWith(
                                              color: scheme.outline
                                                  .withValues(alpha: 0.95),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
