import 'package:flutter/material.dart';

import '../../core/models/local_action_model.dart';
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
    final pad = compact ? AppSpacing.sm : AppSpacing.md;
    final vGap = compact ? AppSpacing.xxs : AppSpacing.xs;

    Widget chip(String label, {bool primary = false}) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: primary
              ? scheme.primaryContainer.withValues(alpha: 0.55)
              : scheme.surfaceContainerHighest.withValues(alpha: 0.65),
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
              color: primary
                  ? scheme.onPrimaryContainer
                  : scheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.06),
            blurRadius: AppSpacing.shadowBlurCard,
            offset: AppSpacing.shadowOffsetCard,
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
                chip('SIMULADO'),
              ],
            ),
            SizedBox(height: vGap),
            Text(
              action.title,
              style: (compact ? text.titleSmall : text.titleMedium)?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.25,
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
          ],
        ),
      ),
    );
  }
}
