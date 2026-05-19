import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Cabecera de marca: logotipo textual Aris + subtítulo breve.
class HomeBrandHeader extends StatelessWidget {
  const HomeBrandHeader({
    super.key,
    this.subtitle = 'Una forma más inteligente de organizar tu día',
    this.onAssistantTap,
  });

  final String subtitle;
  final VoidCallback? onAssistantTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aris',
                  style: text.headlineMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle,
                  style: text.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (onAssistantTap != null) ...[
            const SizedBox(width: AppSpacing.xs),
            IconButton.filledTonal(
              onPressed: onAssistantTap,
              tooltip: 'Hablar con Aris',
              style: IconButton.styleFrom(
                minimumSize: const Size(
                  AppSpacing.minTouchTarget,
                  AppSpacing.minTouchTarget,
                ),
              ),
              icon: Icon(Icons.auto_awesome_rounded, color: scheme.primary),
            ),
          ],
        ],
      ),
    );
  }
}
