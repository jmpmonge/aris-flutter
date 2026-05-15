import 'package:flutter/material.dart';

/// Tokens Aris: **azul profundo** + **violeta suave**, fondos crema en claro y grises cálidos.
abstract final class AppColors {
  /// Primario — azul profundo (marca, acentos principales).
  static const Color primaryDeep = Color(0xFF1B3554);
  static const Color primaryMid = Color(0xFF274A6E);
  static const Color primarySoft = Color(0xFF4A6D8C);

  /// Secundario — violeta suave (detalles, chips, asistente secundario).
  static const Color violetSoft = Color(0xFF7D6BA8);
  static const Color violetMuted = Color(0xFF9D8FC4);
  static const Color violetContainer = Color(0xFFEDE8F5);
  static const Color violetContainerDark = Color(0xFF2F2840);

  /// Lienzo y superficies — blanco / crema cálido (modo claro).
  static const Color canvasLight = Color(0xFFF7F4EE);
  static const Color surfaceLight = Color(0xFFFFFCF8);
  static const Color surfaceRaisedLight = Color(0xFFF0EDE6);
  static const Color surfaceTintLight = Color(0xFFE8E4DC);

  /// Texto y contornos — grises cálidos (claro).
  static const Color textPrimaryLight = Color(0xFF252220);
  static const Color textSecondaryLight = Color(0xFF5C5752);
  static const Color textTertiaryLight = Color(0xFF8A837B);

  static const Color outlineLight = Color(0xFFDDD7CD);
  static const Color outlineVariantLight = Color(0xFFEBE6DD);

  /// Modo oscuro — superficies con calidez (no gris puro frío).
  static const Color canvasDark = Color(0xFF141210);
  static const Color surfaceDark = Color(0xFF1C1A17);
  static const Color surfaceRaisedDark = Color(0xFF252320);
  static const Color surfaceTintDark = Color(0xFF2E2B27);

  static const Color textPrimaryDark = Color(0xFFF2EDE6);
  static const Color textSecondaryDark = Color(0xFFB8B2A8);
  static const Color textTertiaryDark = Color(0xFF8E887F);

  static const Color outlineDark = Color(0xFF3D3934);
  static const Color outlineVariantDark = Color(0xFF2A2723);

  static const Color danger = Color(0xFFB3261E);
  static const Color success = Color(0xFF3D7A52);

  /// Sombra suave para tarjetas (alpha aplicado sobre tono cálido).
  static const Color shadowWarm = Color(0x40181008);

  static ColorScheme get lightScheme {
    return ColorScheme(
      brightness: Brightness.light,
      primary: primaryDeep,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFC8D8EC),
      onPrimaryContainer: const Color(0xFF061325),
      secondary: violetSoft,
      onSecondary: Colors.white,
      secondaryContainer: violetContainer,
      onSecondaryContainer: const Color(0xFF1F1530),
      tertiary: const Color(0xFFC9A66E),
      onTertiary: const Color(0xFF2B1E0C),
      tertiaryContainer: const Color(0xFFEEDCC4),
      onTertiaryContainer: const Color(0xFF3D2912),
      error: danger,
      onError: Colors.white,
      errorContainer: const Color(0xFFF9DEDC),
      onErrorContainer: const Color(0xFF410E0B),
      surface: surfaceLight,
      onSurface: textPrimaryLight,
      surfaceContainerLowest: surfaceLight,
      surfaceContainerLow: surfaceLight,
      surfaceContainer: surfaceRaisedLight,
      surfaceContainerHigh: surfaceTintLight,
      surfaceContainerHighest: surfaceRaisedLight,
      onSurfaceVariant: textSecondaryLight,
      outline: outlineLight,
      outlineVariant: outlineVariantLight,
      shadow: shadowWarm,
      scrim: const Color(0x80000000),
      inverseSurface: surfaceDark,
      onInverseSurface: textPrimaryDark,
      inversePrimary: const Color(0xFF9FBFE0),
    );
  }

  static ColorScheme get darkScheme {
    return ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFF9BB4DA),
      onPrimary: const Color(0xFF0C1624),
      primaryContainer: primaryMid,
      onPrimaryContainer: const Color(0xFFE3ECF7),
      secondary: const Color(0xFFCDBFE8),
      onSecondary: const Color(0xFF1E1530),
      secondaryContainer: violetContainerDark,
      onSecondaryContainer: const Color(0xFFE8E3F2),
      tertiary: const Color(0xFFE5C79A),
      onTertiary: const Color(0xFF1E1408),
      tertiaryContainer: const Color(0xFF4A3820),
      onTertiaryContainer: const Color(0xFFF6E8D8),
      error: const Color(0xFFF2B8B5),
      onError: const Color(0xFF601410),
      errorContainer: const Color(0xFF8C1D18),
      onErrorContainer: const Color(0xFFF9DEDC),
      surface: surfaceDark,
      onSurface: textPrimaryDark,
      surfaceContainerLowest: canvasDark,
      surfaceContainerLow: surfaceDark,
      surfaceContainer: surfaceRaisedDark,
      surfaceContainerHigh: surfaceTintDark,
      surfaceContainerHighest: surfaceTintDark,
      onSurfaceVariant: textSecondaryDark,
      outline: outlineDark,
      outlineVariant: outlineVariantDark,
      shadow: Colors.black.withValues(alpha: 0.45),
      scrim: const Color(0x99000000),
      inverseSurface: surfaceLight,
      onInverseSurface: textPrimaryLight,
      inversePrimary: primaryDeep,
    );
  }
}
