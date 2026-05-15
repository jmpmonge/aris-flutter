import 'package:flutter/material.dart';

/// Tokens de color Clara / Aris: cálido, sobrio y premium (sin negro puro).
abstract final class AppColors {
  /// Marca Aris — azul-verdoso profundo.
  static const Color arisDeep = Color(0xFF2A4D5C);

  static const Color arisMid = Color(0xFF3E6574);
  static const Color arisSoft = Color(0xFF6F8F9B);

  /// Presencia Clara — acento cálido arena / dorado suave (no competir con primario).
  static const Color claraAccent = Color(0xFFD4A574);
  static const Color claraAccentSoft = Color(0xFFEFDEC8);
  static const Color claraWhisper = Color(0xFFF5EBE0);

  /// Lienzo y superficies (blancos cálidos).
  static const Color canvas = Color(0xFFF3EFE8);
  static const Color surface = Color(0xFFFFFBF7);
  static const Color surfaceRaised = Color(0xFFF0EBE3);
  static const Color surfaceTint = Color(0xFFE7E1D8);

  /// Texto y contornos.
  static const Color textPrimary = Color(0xFF1E1C19);
  static const Color textSecondary = Color(0xFF6B6560);
  static const Color textTertiary = Color(0xFF9A948C);

  static const Color borderSubtle = Color(0xFFE0D9CF);
  static const Color borderStrong = Color(0xFFC9C2B8);

  static const Color danger = Color(0xFFB3261E);
  static const Color success = Color(0xFF387A4A);

  /// [ColorScheme] Material 3 alineado con los tokens anteriores.
  static ColorScheme get lightScheme {
    return ColorScheme.fromSeed(
      seedColor: arisDeep,
      brightness: Brightness.light,
    ).copyWith(
      primary: arisDeep,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFCFE3EA),
      onPrimaryContainer: const Color(0xFF082028),
      secondary: arisMid,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFCED9DE),
      onSecondaryContainer: const Color(0xFF141F24),
      tertiary: claraAccent,
      onTertiary: const Color(0xFF271B11),
      tertiaryContainer: claraAccentSoft,
      onTertiaryContainer: const Color(0xFF3D2914),
      error: danger,
      onError: Colors.white,
      errorContainer: const Color(0xFFF9DEDC),
      onErrorContainer: const Color(0xFF410E0B),
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      surfaceContainerLow: surface,
      surfaceContainer: surfaceRaised,
      surfaceContainerHigh: surfaceTint,
      surfaceContainerHighest: surfaceRaised,
      outline: borderSubtle,
      outlineVariant: const Color(0xFFECE7DF),
      shadow: const Color(0x332A2415),
      scrim: const Color(0x66000000),
    );
  }
}
