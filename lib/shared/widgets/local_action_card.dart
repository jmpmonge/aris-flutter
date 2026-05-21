import 'package:flutter/material.dart';

import '../../core/models/local_action_model.dart';
import '../../core/services/local_action_service.dart';
import '../../theme/app_spacing.dart';

/// Tarjeta premium para acciones locales simuladas creadas por Aris.
class LocalActionCard extends StatelessWidget {
  const LocalActionCard({
    super.key,
    required this.action,
    this.compact = false,
  });

  final LocalActionModel action;
  final bool compact;

  String _timeLine(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} · '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pad = compact ? 10.0 : AppSpacing.md;
    final vGap = compact ? AppSpacing.xxs : AppSpacing.xs;
    final completed = action.status == LocalActionStatus.completed;

    Widget chip(String label, {bool primary = false, bool accent = false}) {
      final bg = accent
          ? scheme.tertiaryContainer.withValues(alpha: 0.45)
          : primary
              ? scheme.primaryContainer.withValues(alpha: 0.55)
              : scheme.surfaceContainerHighest.withValues(alpha: 0.65);
      final fg = accent
          ? scheme.onTertiaryContainer
          : primary
              ? scheme.onPrimaryContainer
              : scheme.onSurfaceVariant;
      return DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.16)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: 2,
          ),
          child: Text(
            label,
            style: text.labelSmall?.copyWith(
              letterSpacing: 0.55,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ),
      );
    }

    // v0.49.15: sin chips de categoría/etiqueta en notas (noteCategory omitido).
    final metaChips = <Widget>[
      if (action.taskPriority != null)
        chip(action.taskPriority!.displayLabel, primary: false),
      if (action.eventWhenText != null && action.eventWhenText!.isNotEmpty)
        chip(action.eventWhenText!, primary: false),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(
          compact ? AppSpacing.homeCardRadius : AppSpacing.radiusLg,
        ),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(
              alpha: isDark
                  ? 0.05
                  : compact
                      ? 0.07
                      : 0.11,
            ),
            blurRadius: compact
                ? AppSpacing.shadowBlurHomeCard
                : AppSpacing.shadowBlurCard,
            offset: compact
                ? AppSpacing.shadowOffsetHomeCard
                : AppSpacing.shadowOffsetCard,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xxs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                chip(action.typeShortLabel, primary: true),
                chip('SIMULADO', accent: true),
                chip(action.operationalStatusLabel),
                ...metaChips,
              ],
            ),
            SizedBox(height: vGap),
            Text(
              action.title,
              style: (compact ? text.titleSmall : text.titleMedium)?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.25,
                decoration: completed
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: completed ? scheme.onSurfaceVariant : null,
              ),
            ),
            SizedBox(height: compact ? AppSpacing.xxs : AppSpacing.xs),
            Text(
              action.description,
              maxLines: compact ? 2 : 4,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            SizedBox(height: compact ? AppSpacing.xxs : AppSpacing.sm),
            Text(
              _timeLine(action.createdAt),
              style: text.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.88),
                letterSpacing: 0.4,
              ),
            ),
            if (!compact) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (action.type == LocalActionType.task ||
                      action.type == LocalActionType.mail)
                    IconButton.filledTonal(
                      tooltip: completed ? 'Marcar pendiente' : 'Completar',
                      icon: Icon(
                        completed
                            ? Icons.undo_rounded
                            : Icons.check_rounded,
                      ),
                      onPressed: () =>
                          LocalActionService.toggleActionCompleted(action.id),
                    ),
                  IconButton(
                    tooltip: 'Eliminar',
                    icon: const Icon(Icons.delete_outline_rounded),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(
                        AppSpacing.minTouchTarget,
                        AppSpacing.minTouchTarget,
                      ),
                    ),
                    onPressed: () =>
                        LocalActionService.removeAction(action.id),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
