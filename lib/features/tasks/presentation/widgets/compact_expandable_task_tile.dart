import 'package:flutter/material.dart';

import '../../../../core/models/task_model.dart';
import '../../../../core/models/task_ui_buckets.dart';
import '../../../../theme/app_spacing.dart';

/// Tarjeta compacta de tarea con check y expansión inline (v0.49.18).
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

  static const double _checkSlot = 22;
  static const double _checkTextGap = 10;
  static const double _cardRadius = 14;

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
          ? scheme.onSurfaceVariant.withValues(alpha: 0.72)
          : scheme.onSurface,
      height: 1.2,
      fontWeight: FontWeight.w600,
      fontSize: 15,
    );

    final metaStyle = tt.bodySmall?.copyWith(
      color: strike
          ? scheme.onSurfaceVariant.withValues(alpha: 0.45)
          : scheme.onSurfaceVariant.withValues(alpha: 0.72),
      height: 1.2,
      fontSize: 12,
    );

    final desc = (widget.task.description ?? '').trim();
    final hasDesc = desc.isNotEmpty;
    final tagsLabel =
        widget.task.tags.where((x) => x.trim().isNotEmpty).join(' · ');
    final hasTags = tagsLabel.isNotEmpty;
    final hasExpandedBody = hasDesc || hasTags;

    void toggleExpanded() => setState(() => _open = !_open);

    final detailBlock = _open && hasExpandedBody
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: scheme.outline.withValues(alpha: 0.18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasDesc)
                      Text(
                        desc,
                        style: tt.bodySmall?.copyWith(
                          height: 1.4,
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.9),
                        ),
                      ),
                    if (hasTags)
                      Padding(
                        padding: EdgeInsets.only(
                          top: hasDesc ? AppSpacing.xs : 0,
                        ),
                        child: Text(
                          tagsLabel,
                          style: tt.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant
                                .withValues(alpha: 0.65),
                            height: 1.3,
                            letterSpacing: 0.15,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          )
        : const SizedBox.shrink();

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shadowColor: Colors.transparent,
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
        side: BorderSide(
          color: scheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm + 2,
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
                  value: widget.task.completed,
                  onChanged: widget.busy ? null : widget.onCheckboxChanged,
                ),
              ),
            ),
            SizedBox(width: _checkTextGap),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: toggleExpanded,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusSm),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 1,
                      right: AppSpacing.xs,
                      bottom: 1,
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
                                  fontSize: 14,
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
                                      EdgeInsets.only(left: AppSpacing.xxs),
                                  child: Icon(
                                    Icons.more_vert_rounded,
                                    size: 18,
                                    color: scheme.onSurfaceVariant
                                        .withValues(alpha: 0.55),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (meta.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(meta, style: metaStyle),
                          ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topLeft,
                          child: detailBlock,
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
