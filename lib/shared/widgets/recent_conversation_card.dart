import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Bloque **RECIENTE** con burbujas tipo chat (mock).
class RecentConversationCard extends StatelessWidget {
  const RecentConversationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.07),
              blurRadius: AppSpacing.shadowBlurChat,
              offset: AppSpacing.shadowOffsetChat,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RECIENTE',
                style: text.titleSmall?.copyWith(
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _Bubble(
                alignLeft: true,
                label: 'ARIS',
                text:
                    'He agrupado tus reuniones de la tarde. ¿Quieres que te avise 15 min antes?',
                scheme: scheme,
                textTheme: text,
              ),
              const SizedBox(height: AppSpacing.sm),
              _Bubble(
                alignLeft: false,
                label: 'TÚ',
                text: 'Sí, avísame para las 15:15.',
                scheme: scheme,
                textTheme: text,
              ),
              const SizedBox(height: AppSpacing.sm),
              _Bubble(
                alignLeft: true,
                label: 'ARIS',
                text:
                    'Listo. Es solo una demostración — sin notificaciones reales.',
                scheme: scheme,
                textTheme: text,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.alignLeft,
    required this.label,
    required this.text,
    required this.scheme,
    required this.textTheme,
  });

  final bool alignLeft;
  final String label;
  final String text;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      constraints: const BoxConstraints(
        maxWidth: AppSpacing.chatBubbleMaxWidth,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: alignLeft ? scheme.surfaceContainerHigh : scheme.primary,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppSpacing.radiusMd),
          topRight: const Radius.circular(AppSpacing.radiusMd),
          bottomLeft: Radius.circular(
            alignLeft ? AppSpacing.radiusTail : AppSpacing.radiusMd,
          ),
          bottomRight: Radius.circular(
            alignLeft ? AppSpacing.radiusMd : AppSpacing.radiusTail,
          ),
        ),
        border: alignLeft
            ? Border.all(color: scheme.outline.withValues(alpha: 0.2))
            : null,
        boxShadow: alignLeft
            ? null
            : [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.22),
                  blurRadius: AppSpacing.shadowBlurLift,
                  offset: AppSpacing.shadowOffsetLift,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              letterSpacing: 0.8,
              color: alignLeft
                  ? scheme.secondary
                  : scheme.onPrimary.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            text,
            style: textTheme.bodyMedium?.copyWith(
              color: alignLeft ? scheme.onSurface : scheme.onPrimary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );

    return Align(
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: bubble,
    );
  }
}
