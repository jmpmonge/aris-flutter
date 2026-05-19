import 'package:flutter/material.dart';

import '../../../../core/services/user_service.dart';
import '../../../../theme/app_spacing.dart';

/// Fecha fija superior Home — siempre visible (v0.48.41).
class HomeFixedDateHeader extends StatelessWidget {
  const HomeFixedDateHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.homePageMarginH,
        AppSpacing.homeFixedDateTopGap,
        AppSpacing.homePageMarginH,
        0,
      ),
      child: Text(
        UserService.getHomeFixedDateLine(),
        style: TextStyle(
          fontSize: 13,
          height: 1.15,
          fontWeight: FontWeight.w500,
          color: scheme.onSurfaceVariant.withValues(
            alpha: isDark ? 0.78 : 0.72,
          ),
        ),
      ),
    );
  }
}
