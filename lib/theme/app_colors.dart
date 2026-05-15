import 'package:flutter/material.dart';

/// Tokens Aris: **azul marino** + **violeta premium**, crema cálida en claro; modo oscuro sin rediseño.
abstract final class AppColors {
  /// Primario — azul marino (CTAs, marca, iconos activos en modo claro).
  static const Color primaryDeep = Color(0xFF102A5C);
  static const Color primaryNavyDeep = Color(0xFF071B3A);

  /// Puentes para contenedores en **modo oscuro** (v0.35.1 no altera el dark salvo `inversePrimary`).
  static const Color primaryMid = Color(0xFF274A6E);
  static const Color primarySoft = Color(0xFF4A6D8C);

  /// Secundario — violeta (acento premium; gradientes pueden usar [violetSoft]).
  static const Color violetSoft = Color(0xFF8B7CF6);
  static const Color violetMuted = Color(0xFFA89EF7);
  static const Color violetContainer = Color(0xFFECE9FF);
  static const Color violetContainerDark = Color(0xFF2F2840);

  /// Violeta un poco más saturado para [ColorScheme.secondary] (chips, foco).
  static const Color secondaryViolet = Color(0xFF7B6CF6);

  /// Superficies modo claro — crema / blanco cálido (evita blanco puro en lienzo).
  static const Color canvasLight = Color(0xFFF7F1E8);
  static const Color surfaceLight = Color(0xFFFFFCF8);
  static const Color surfaceRaisedLight = Color(0xFFFEFAF2);
  static const Color surfaceTintLight = Color(0xFFF5EDE3);
  static const Color surfaceInputLight = Color(0xFFEFE8DE);

  /// Texto y contornos (claro) — tonos azulados, legibles.
  static const Color textPrimaryLight = Color(0xFF102A43);
  static const Color textSecondaryLight = Color(0xFF5C667A);
  static const Color textTertiaryLight = Color(0xFF7A8499);

  static const Color outlineLight = Color(0xFFE8DFD2);
  static const Color outlineVariantLight = Color(0xFFF3EDE4);

  /// Sobre primario / secundario / error en claro (blanco cálido).
  static const Color onPrimaryContrast = Color(0xFFFFFBF7);

  /// Pastel documentados (extensiones UI, chips).
  static const Color softBlue = Color(0xFFEAF1FF);
  static const Color softGreen = Color(0xFFEAF7EF);
  static const Color softOrange = Color(0xFFFFF0DF);
  static const Color softPurple = Color(0xFFEFEAFF);

  /// Modo oscuro — paleta existente.
  static const Color canvasDark = Color(0xFF121820);
  static const Color surfaceDark = Color(0xFF1A222C);
  static const Color surfaceRaisedDark = Color(0xFF242E3A);
  static const Color surfaceTintDark = Color(0xFF2F3A48);

  static const Color textPrimaryDark = Color(0xFFE8EEF4);
  static const Color textSecondaryDark = Color(0xFFB4BCC6);
  static const Color textTertiaryDark = Color(0xFF858D98);

  static const Color outlineDark = Color(0xFF3D4A5C);
  static const Color outlineVariantDark = Color(0xFF2A3440);

  static const Color danger = Color(0xFFB3261E);
  static const Color success = Color(0xFF25A66A);

  /// Sombra modo claro — tinte marino, visible sobre crema.
  static const Color shadowWarmLight = Color(0x45102A5C);

  static ColorScheme get lightScheme {
    return ColorScheme(
      brightness: Brightness.light,
      primary: primaryDeep,
      onPrimary: onPrimaryContrast,
      primaryContainer: softBlue,
      onPrimaryContainer: primaryNavyDeep,
      secondary: secondaryViolet,
      onSecondary: onPrimaryContrast,
      secondaryContainer: violetContainer,
      onSecondaryContainer: Color(0xFF2A1F55),
      tertiary: success,
      onTertiary: onPrimaryContrast,
      tertiaryContainer: softGreen,
      onTertiaryContainer: Color(0xFF0A4D32),
      error: danger,
      onError: onPrimaryContrast,
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF410E0B),
      surface: surfaceLight,
      onSurface: textPrimaryLight,
      surfaceContainerLowest: canvasLight,
      surfaceContainerLow: surfaceRaisedLight,
      surfaceContainer: surfaceTintLight,
      surfaceContainerHigh: surfaceInputLight,
      surfaceContainerHighest: Color(0xFFE8E0D6),
      onSurfaceVariant: textSecondaryLight,
      outline: outlineLight,
      outlineVariant: outlineVariantLight,
      shadow: shadowWarmLight,
      scrim: Color(0x80000000),
      inverseSurface: surfaceDark,
      onInverseSurface: textPrimaryDark,
      inversePrimary: Color(0xFF8FABD9),
    );
  }

  static ColorScheme get darkScheme {
    return ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF9BB4DA),
      onPrimary: Color(0xFF0C1624),
      primaryContainer: primaryMid,
      onPrimaryContainer: Color(0xFFE3ECF7),
      secondary: Color(0xFFCDBFE8),
      onSecondary: Color(0xFF1E1530),
      secondaryContainer: violetContainerDark,
      onSecondaryContainer: Color(0xFFE8E3F2),
      tertiary: Color(0xFFE5C79A),
      onTertiary: Color(0xFF1E1408),
      tertiaryContainer: Color(0xFF4A3820),
      onTertiaryContainer: Color(0xFFF6E8D8),
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      errorContainer: Color(0xFF8C1D18),
      onErrorContainer: Color(0xFFF9DEDC),
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
      shadow: Colors.black.withValues(alpha: 0.35),
      scrim: Color(0x99000000),
      inverseSurface: surfaceLight,
      onInverseSurface: textPrimaryLight,
      inversePrimary: primaryDeep,
    );
  }
}
