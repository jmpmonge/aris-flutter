import 'package:flutter/material.dart';

import '../../../../core/services/user_service.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';

/// Fecha fija + configuración — inset simétrico con saludo (v0.49.31).
class HomeFixedDateHeader extends StatelessWidget {
  const HomeFixedDateHeader({
    super.key,
    this.onOpenSettings,
  });

  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final dateColor = isDark
        ? AppColors.textSecondaryDark.withValues(alpha: 0.88)
        : AppColors.textSecondaryLight;

    // Mismo inset que «Hola, José»: homePageMarginH + homeCardPadding (32 px).
    const horizontalInset = AppSpacing.homeFixedDateLeftInsetH;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        horizontalInset,
        AppSpacing.homeFixedDateTopGap,
        horizontalInset,
        AppSpacing.homeFixedDateMinPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              UserService.getHomeFixedDateLine(),
              style: TextStyle(
                fontSize: 12,
                height: 1.2,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.1,
                color: dateColor,
              ),
            ),
          ),
          if (onOpenSettings != null)
            _HomeSettingsCircleButton(
              onPressed: onOpenSettings!,
              iconColor: scheme.onSurfaceVariant.withValues(alpha: 0.82),
              borderColor: scheme.outlineVariant.withValues(
                alpha: isDark ? 0.45 : 0.55,
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeSettingsCircleButton extends StatelessWidget {
  const _HomeSettingsCircleButton({
    required this.onPressed,
    required this.iconColor,
    required this.borderColor,
  });

  final VoidCallback onPressed;
  final Color iconColor;
  final Color borderColor;

  static const double _size = 32;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: _size,
          height: _size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Icon(
            Icons.more_horiz_rounded,
            size: 18,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
