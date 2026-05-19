import 'package:flutter/material.dart';

import '../../../../core/services/user_service.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';

/// Fecha fija superior — alineada con tarjetas Home (v0.48.37).
class CompactHomeDateHeader extends StatelessWidget {
  const CompactHomeDateHeader({super.key, this.embedded = false});

  /// Si true, el padre ya aplica [AppSpacing.homePageMarginH] (fila con avatar).
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final dateText = Text(
      UserService.getHomeFixedDateLine(),
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
    );

    if (embedded) {
      return Padding(
        padding: const EdgeInsets.only(left: AppSpacing.homeCardPadding),
        child: Align(
          alignment: Alignment.centerLeft,
          child: dateText,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.homeFixedDateLeftInsetH,
        right: AppSpacing.homePageMarginH,
      ),
      child: SizedBox(
        width: double.infinity,
        child: dateText,
      ),
    );
  }
}
