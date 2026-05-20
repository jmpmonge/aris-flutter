import 'package:flutter/material.dart';

import '../../../../core/services/user_service.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';

/// Fecha fija superior Home — siempre visible (v0.48.41).
class HomeFixedDateHeader extends StatelessWidget {
  const HomeFixedDateHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.homeFixedDateLeftInsetH,
        AppSpacing.homeFixedDateTopGap,
        AppSpacing.homePageMarginH,
        AppSpacing.homeFixedDateMinPadding,
      ),
      child: Text(
        UserService.getHomeFixedDateLine(),
        style: TextStyle(
          fontSize: 13,
          height: 1.15,
          fontWeight: FontWeight.w500,
          color: isDark
              ? AppColors.textTertiaryDark.withValues(alpha: 0.95)
              : AppColors.textTertiaryLight,
        ),
      ),
    );
  }
}
