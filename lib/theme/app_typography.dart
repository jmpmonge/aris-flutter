import 'package:flutter/material.dart';

/// Tipografía mobile-first — v0.48.2 escala alineada con Home Structured.
abstract final class AppTypography {
  static TextTheme textTheme(ColorScheme colors) {
    final on = colors.onSurface;
    final muted = colors.onSurfaceVariant;

    TextStyle base(
      double size,
      FontWeight w, {
      double height = 1.35,
      double ls = 0,
      Color? color,
    }) {
      return TextStyle(
        color: color ?? on,
        fontSize: size,
        fontWeight: w,
        height: height,
        letterSpacing: ls,
        leadingDistribution: TextLeadingDistribution.even,
      );
    }

    return TextTheme(
      displaySmall: base(32, FontWeight.w700, height: 1.12, ls: -0.45),
      headlineMedium: base(28, FontWeight.w700, height: 1.15, ls: -0.35),
      headlineSmall: base(22, FontWeight.w700, height: 1.18, ls: -0.25),
      titleLarge: base(17, FontWeight.w700, height: 1.22, ls: -0.12),
      titleMedium: base(15, FontWeight.w600, height: 1.26, ls: -0.08),
      titleSmall: base(14, FontWeight.w600, height: 1.28, ls: -0.04),
      bodyLarge: base(15, FontWeight.w400, height: 1.34),
      bodyMedium: base(14, FontWeight.w400, height: 1.34),
      bodySmall: base(13, FontWeight.w400, height: 1.30, color: muted),
      labelLarge: base(14, FontWeight.w700, height: 1.18, ls: 0.12),
      labelMedium: base(
        12,
        FontWeight.w700,
        height: 1.16,
        ls: 0.7,
        color: muted,
      ),
      labelSmall: base(
        11,
        FontWeight.w700,
        height: 1.14,
        ls: 0.7,
        color: muted,
      ),
    );
  }

  /// Alias explícito histórico.
  static TextTheme lightTextTheme(ColorScheme colors) => textTheme(colors);
}
