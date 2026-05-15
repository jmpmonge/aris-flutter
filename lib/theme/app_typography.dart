import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tipografía legible mobile-first. Usa fuentes del sistema (SF en iOS).
abstract final class AppTypography {
  static TextTheme lightTextTheme(ColorScheme colors) {
    final on = colors.onSurface;
    final muted = colors.onSurfaceVariant;

    TextStyle base(double size, FontWeight w, {double height = 1.35, double ls = 0}) {
      return TextStyle(
        color: on,
        fontSize: size,
        fontWeight: w,
        height: height,
        letterSpacing: ls,
        leadingDistribution: TextLeadingDistribution.even,
      );
    }

    return TextTheme(
      displaySmall: base(32, FontWeight.w600, height: 1.2, ls: -0.6),
      headlineMedium: base(26, FontWeight.w600, height: 1.22, ls: -0.4),
      headlineSmall: base(22, FontWeight.w600, height: 1.25, ls: -0.35),
      titleLarge: base(20, FontWeight.w600, height: 1.28, ls: -0.3),
      titleMedium: base(18, FontWeight.w600, height: 1.3, ls: -0.2),
      titleSmall: base(16, FontWeight.w600, height: 1.32, ls: -0.1),
      bodyLarge: base(17, FontWeight.w400, height: 1.38),
      bodyMedium: base(15, FontWeight.w400, height: 1.38),
      bodySmall: base(13, FontWeight.w400, height: 1.35).copyWith(color: muted),
      labelLarge: base(15, FontWeight.w600, height: 1.2, ls: 0.15),
      labelMedium: base(13, FontWeight.w600, height: 1.2, ls: 0.2).copyWith(color: muted),
      labelSmall: base(11, FontWeight.w600, height: 1.2, ls: 0.35).copyWith(color: AppColors.textTertiary),
    );
  }
}
