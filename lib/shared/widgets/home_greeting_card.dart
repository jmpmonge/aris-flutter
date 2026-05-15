import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Tarjeta protagonista de saludo + resumen del día (pastel / degradado suave).
class HomeGreetingCard extends StatelessWidget {
  const HomeGreetingCard({
    super.key,
    required this.greeting,
    required this.summary,
    this.leadingIcon = Icons.wb_sunny_rounded,
  });

  final String greeting;
  final String summary;
  final IconData leadingIcon;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradientColors = isDark
        ? [
            scheme.primaryContainer.withValues(alpha: 0.55),
            scheme.tertiaryContainer.withValues(alpha: 0.4),
          ]
        : [
            scheme.primaryContainer.withValues(alpha: 0.75),
            scheme.tertiaryContainer.withValues(alpha: 0.55),
          ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: isDark ? 0.35 : 0.12),
              blurRadius: AppSpacing.shadowBlurHero,
              offset: AppSpacing.shadowOffsetHero,
            ),
          ],
          border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    leadingIcon,
                    color: scheme.primary,
                    size: AppSpacing.iconLg,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      greeting,
                      style: text.headlineSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                summary,
                style: text.bodyLarge?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.88),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
