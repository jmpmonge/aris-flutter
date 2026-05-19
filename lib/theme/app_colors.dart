import 'package:flutter/material.dart';

/// Tokens Aris: **azul marino** + **violeta premium**, crema cálida en claro; modo oscuro sin rediseño.
abstract final class AppColors {
  /// Primario — azul marino (CTAs, marca, iconos activos en modo claro).
  /// Paleta v0.48.5 documentada: #102A56 / #071B3F.
  static const Color primaryDeep = Color(0xFF102A56);
  static const Color primaryNavyDeep = Color(0xFF071B3F);

  /// Puentes para contenedores en **modo oscuro** (v0.35.1 no altera el dark salvo `inversePrimary`).
  static const Color primaryMid = Color(0xFF274A6E);
  static const Color primarySoft = Color(0xFF4A6D8C);

  /// Secundario — violeta (acento premium; gradientes pueden usar [violetSoft]).
  static const Color violetSoft = Color(0xFF8B7CF6);
  static const Color violetMuted = Color(0xFFA89EF7);
  static const Color violetContainer = Color(0xFFECE9FF);
  static const Color violetContainerDark = Color(0xFF2F2840);

  /// Violeta IA (acento; [ColorScheme.secondary]).
  static const Color secondaryViolet = Color(0xFF7B6FF2);

  /// Superficies modo claro — crema / blanco cálido (v0.48.5+).
  static const Color canvasLight = Color(0xFFF8F4EE);
  static const Color surfaceLight = Color(0xFFFFFDF8);
  static const Color surfaceRaisedLight = Color(0xFFFEFAF2);
  static const Color surfaceTintLight = Color(0xFFF5EDE3);
  static const Color surfaceInputLight = Color(0xFFEFE8DE);

  /// Texto y contornos (claro) — v0.48.5.
  static const Color textPrimaryLight = Color(0xFF132B4F);
  static const Color textSecondaryLight = Color(0xFF6E7480);
  static const Color textTertiaryLight = Color(0xFF7A8499);

  /// Línea divisoria Home HOY (v0.48.6).
  static const Color outlineLight = Color(0xFFE6E1DA);
  static const Color outlineVariantLight = Color(0xFFF0EBE2);

  /// Sobre primario / secundario / error en claro (blanco cálido).
  static const Color onPrimaryContrast = Color(0xFFFFFBF7);

  /// Calendario / eventos (HOY).
  static const Color calendarBlue = Color(0xFF2F7DF6);

  /// Fondo calendario / agenda suave (referencia Clara).
  static const Color calendarSurfaceSoft = Color(0xFFDDEBFF);

  /// Sugerencia Home — verde (v0.48.6).
  static const Color suggestionGreen = Color(0xFF2FAE68);
  static const Color suggestionSurfacePale = Color(0xFFF7FBF7);
  static const Color suggestionIconBackground = Color(0xFFDDF4E6);

  /// Tarea pendiente HOY — gris azulado (no verde).
  static const Color taskPendingMuted = Color(0xFF9AA3B2);

  /// Tarea completada / validación.
  static const Color taskCompletedGreen = Color(0xFF28A95F);

  /// Legado — preferir [taskCompletedGreen] / [suggestionGreen] según contexto.
  static const Color taskGreen = Color(0xFF45B36B);

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

  /// Modo oscuro — v0.48.21: neutros azulados, sin morado; referencia brief Aris.
  static ColorScheme get darkScheme {
    const kCanvas = Color(0xFF0F1117);
    const kSurface = Color(0xFF171A22);
    const kSurfaceRaised = Color(0xFF202634);
    const kOutline = Color(0xFF3A4354);
    const kPrimary = Color(0xFF7DB7FF);
    const kOnPrimary = Color(0xFF0C1624);
    const kTextPrimary = Color(0xFFE8ECF4);
    const kTextSecondary = Color(0xFFC3CAD6);

    return ColorScheme(
      brightness: Brightness.dark,
      primary: kPrimary,
      onPrimary: kOnPrimary,
      primaryContainer: const Color(0xFF10243F),
      onPrimaryContainer: kTextPrimary,
      secondary: kTextSecondary,
      onSecondary: kCanvas,
      secondaryContainer: kSurfaceRaised,
      onSecondaryContainer: kTextPrimary,
      tertiary: const Color(0xFFAEB6C8),
      onTertiary: kCanvas,
      tertiaryContainer: surfaceRaisedDark,
      onTertiaryContainer: kTextPrimary,
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      errorContainer: Color(0xFF8C1D18),
      onErrorContainer: Color(0xFFF9DEDC),
      surface: kSurface,
      onSurface: kTextPrimary,
      surfaceContainerLowest: kCanvas,
      surfaceContainerLow: kSurface,
      surfaceContainer: kSurfaceRaised,
      surfaceContainerHigh: const Color(0xFF263044),
      surfaceContainerHighest: surfaceTintDark,
      onSurfaceVariant: kTextSecondary,
      outline: kOutline,
      outlineVariant: const Color(0xFF2A2F3A),
      shadow: Colors.black.withValues(alpha: 0.35),
      scrim: Color(0x99000000),
      inverseSurface: surfaceLight,
      onInverseSurface: textPrimaryLight,
      inversePrimary: primaryDeep,
    );
  }
}
