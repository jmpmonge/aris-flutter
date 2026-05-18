import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Tarjeta de sugerencia — v0.48.2 Structured (aviso compacto-premium).
class SuggestionCard extends StatelessWidget {
  const SuggestionCard({
    super.key,
    this.label = 'SUGERENCIA',
    required this.message,
  });

  final String label;
  final String message;

  static const double _cardHeight = 82;
  static const double _radius = AppSpacing.homeCardRadius;
  static const double _padH = 14;
  static const double _leadingIconSize = 28;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final labelStyle = TextStyle(
      fontSize: 11.5,
      letterSpacing: 0.7,
      color: scheme.secondary,
      fontWeight: FontWeight.w700,
      height: 1.0,
    );

    final bodyStyle = TextStyle(
      fontSize: 14.5,
      height: 1.28,
      fontWeight: FontWeight.w400,
      color: scheme.onSurfaceVariant,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.homePageMarginH),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: isDark ? 0.04 : 0.07),
              blurRadius: AppSpacing.shadowBlurHomeCard,
              offset: AppSpacing.shadowOffsetHomeCard,
            ),
          ],
        ),
        child: SizedBox(
          height: _cardHeight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(_padH, 10, _padH, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.tips_and_updates_rounded,
                  size: _leadingIconSize,
                  color: scheme.secondary.withValues(alpha: 0.95),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(label, style: labelStyle),
                      const SizedBox(height: 7),
                      Text(
                        message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: bodyStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
