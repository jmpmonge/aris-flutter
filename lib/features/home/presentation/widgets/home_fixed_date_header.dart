import 'package:flutter/material.dart';

import '../../../../core/services/user_service.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';

/// Fecha fija superior Home — ancla diaria discreta (v0.49.24).
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
          fontSize: 12,
          height: 1.2,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
          color: isDark
              ? AppColors.textSecondaryDark.withValues(alpha: 0.88)
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}
