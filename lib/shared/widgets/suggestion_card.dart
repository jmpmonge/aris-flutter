import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Tarjeta de sugerencia — modo claro sin cambios; v0.48.16 regularización solo oscuro.
class SuggestionCard extends StatelessWidget {
  const SuggestionCard({
    super.key,
    this.label = 'SUGERENCIA',
    required this.message,
  });

  final String label;
  final String message;

  static const double _cardHeight = 86;
  static const double _radius = AppSpacing.homeCardRadius;
  static const double _padH = 14;

  /// Alineación del cuerpo con el título [label] (misma grilla que HOY/CHAT, v0.48.24).
  static double get _bodyTextLeftFromInner =>
      AppSpacing.homeCardHeaderInkPaddingH +
      AppSpacing.homeCardHeaderIconSize +
      AppSpacing.homeCardHeaderIconTitleGap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final accentGreen = AppColors.suggestionGreen;

    /// Solo modo oscuro (títulos/cuerpo v0.48.16; fondo alineado con el resto de tarjetas).
    const kDarkTitle = Color(0xFFE8ECF4);
    const kDarkBody = Color(0xFFC3CAD6);

    final iconTint = accentGreen;

    final labelStyle = TextStyle(
      fontSize: 11.5,
      letterSpacing: 0.7,
      color: isDark ? kDarkTitle : AppColors.primaryDeep,
      fontWeight: FontWeight.w700,
      height: 1.0,
    );

    final bodyStyle = TextStyle(
      fontSize: 14.25,
      height: 1.24,
      fontWeight: FontWeight.w400,
      color: isDark ? kDarkBody : scheme.onSurfaceVariant,
    );

    final cardColor =
        isDark ? scheme.surface : AppColors.suggestionSurfacePale;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.homePageMarginH),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(
            color: scheme.outline.withValues(alpha: 0.18),
          ),
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
            padding: const EdgeInsets.fromLTRB(_padH, 8, _padH, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.homeCardHeaderInkPaddingH,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: AppSpacing.homeCardHeaderIconSize,
                        color: iconTint,
                      ),
                      SizedBox(width: AppSpacing.homeCardHeaderIconTitleGap),
                      Text(label, style: labelStyle),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: EdgeInsets.only(left: _bodyTextLeftFromInner),
                  child: Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: bodyStyle,
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
