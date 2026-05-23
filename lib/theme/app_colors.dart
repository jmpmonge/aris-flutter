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

  /// Superficies modo claro — frío premium iOS (v0.49.86).
  static const Color canvasLight = Color(0xFFF5F7FB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceRaisedLight = Color(0xFFF8FAFD);
  static const Color surfaceTintLight = Color(0xFFF1F5FA);
  static const Color surfaceInputLight = Color(0xFFEEF3FA);

  /// Texto y contornos (claro) — v0.49.86.
  static const Color textPrimaryLight = Color(0xFF142033);
  static const Color textSecondaryLight = Color(0xFF5E6B7D);
  static const Color textTertiaryLight = Color(0xFF8A97A8);

  /// Líneas modo claro.
  static const Color outlineLight = Color(0xFFD9E2EE);
  static const Color outlineVariantLight = Color(0xFFE4EBF3);

  /// Sobre primario / secundario / error en claro (blanco cálido).
  static const Color onPrimaryContrast = Color(0xFFFFFBF7);

  /// Primario claro — azul Aris (v0.49.86).
  static const Color brandBlueLight = Color(0xFF79AFFF);
  static const Color brandBlueStrongLight = Color(0xFF5E97F6);
  static const Color brandBlueDeepLight = Color(0xFF2D5FA8);
  static const Color brandBlueSoftLight = Color(0xFFEAF2FF);
  static const Color brandBlueSurfaceLight = Color(0xFFDCEBFF);

  /// Calendario / eventos (HOY) — claro.
  static const Color calendarBlue = Color(0xFF79AFFF);

  /// Fondo calendario / agenda suave.
  static const Color calendarSurfaceSoft = Color(0xFFDCEBFF);

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

  /// Home claro (v0.49.86).
  static const Color homeHeaderTextLight = Color(0xFF1B2B44);
  static const Color homeTimelineLineLight = Color(0xFFD7E4F5);
  static const Color homeTimelineDotLight = Color(0xFF6EA8FF);
  static const Color homeWeatherAccentLight = Color(0xFFE4B949);
  static const Color noteSectionLabelLight = Color(0xFF7CCB9A);

  /// Navegación claro.
  static const Color navSelectedBackgroundLight = Color(0xFFDCE7FB);
  static const Color navSelectedIconLight = Color(0xFF79AFFF);
  static const Color navInactiveIconLight = Color(0xFF6E7C90);
  static const Color floatingButtonBackgroundLight = Color(0xFF6E98D8);

  /// Perfil claro.
  static const Color profileIconAccentLight = Color(0xFF8FB5FF);
  static const Color profileAvatarBgLight = Color(0xFFDCE7FB);
  static const Color profileAvatarTextLight = Color(0xFF2D5FA8);

  /// Pastel documentados (extensiones UI, chips) — claro v0.49.86.
  static const Color softBlue = Color(0xFFEAF2FF);
  static const Color softGreen = Color(0xFFEAF7EF);
  static const Color softOrange = Color(0xFFFFF0DF);
  static const Color softPurple = Color(0xFFEFEAFF);

  /// Modo oscuro — profundidad y capas (v0.48.33).
  static const Color canvasDark = Color(0xFF0D121A);
  static const Color scaffoldDark = Color(0xFF0F151E);
  static const Color surfaceDark = Color(0xFF171D27);
  static const Color surfaceRaisedDark = Color(0xFF1A202B);
  static const Color surfaceHoverDark = Color(0xFF202938);
  static const Color surfaceContainerLowDark = Color(0xFF111821);

  /// Alias legado (elevación máxima ≈ hover).
  static const Color surfaceTintDark = surfaceHoverDark;

  static const Color textPrimaryDark = Color(0xFFEAF0FA);
  static const Color textSecondaryDark = Color(0xFFB8C0CC);
  static const Color textTertiaryDark = Color(0xFF8F98A8);

  static const Color outlineDark = Color(0xFF293445);
  static const Color outlineVariantDark = Color(0xFF344154);

  /// Acentos modo oscuro (solo iconos / detalle, no fondos dominantes).
  static const Color calendarBlueDark = Color(0xFF7DB7FF);
  static const Color suggestionGreenDark = Color(0xFF5EE0A0);

  /// Módulo MAIL en Home (icono; no morado).
  static const Color mailModuleGreen = suggestionGreen;
  static const Color mailModuleGreenDark = suggestionGreenDark;

  static const Color chatAccentLavenderDark = Color(0xFFB8A7FF);
  static const Color tasksOrangeDark = Color(0xFFFDBA74);

  /// Borde tarjeta Home — opacidad según tema.
  static double homeCardBorderAlpha(Brightness brightness) =>
      brightness == Brightness.dark ? 0.75 : 0.18;

  /// Sombra tarjeta Home en oscuro (muy sutil).
  static double homeCardShadowAlpha(Brightness brightness) =>
      brightness == Brightness.dark ? 0.14 : 0.08;

  static const Color danger = Color(0xFFB3261E);
  static const Color success = Color(0xFF25A66A);

  /// Nota amplia (v0.49.41) — lienzo tipo Apple Notes en oscuro Aris.
  static const Color noteWideCanvas = Color(0xFF07111D);
  static const Color noteWideSurface = Color(0xFF111A25);
  static const Color noteWideBorder = Color(0xFF243244);
  static const Color noteArisBlue = Color(0xFF5EA8FF);
  static const Color noteArisSky = Color(0xFF8FCBFF);
  static const Color noteWideTextPrimary = Color(0xFFF2F6FA);
  static const Color noteWideTextSecondary = Color(0xFFA6B0BE);
  static const Color noteWideTextMuted = Color(0xFF6F7B8A);
  static const Color noteDestructive = Color(0xFFFF5A5A);

  /// Listado de notas (v0.49.43) — tarjetas ligeras tipo Apple Notes.
  static const Color noteListCardFill = noteWideSurface;
  static const Color noteListCardBorder = Color(0x59243244);
  static const Color noteListPinTint = Color(0x995EA8FF);
  static const Color noteListSectionLabel = noteArisBlue;
  static const Color noteListTagTint = Color(0x8F5EA8FF);

  /// Listado de tareas (v0.49.44) — coherente con Notas / lienzo oscuro Aris.
  static const Color taskListCanvas = noteWideCanvas;
  static const Color taskListCardFill = noteWideSurface;
  static const Color taskListCardExpandedFill = Color(0xFF131E2A);
  static const Color taskListBorderNormal = Color(0x40243244);
  static const Color taskListBorderSelected = Color(0x665EA8FF);
  static const Color taskListCardBorder = noteListCardBorder;
  static const Color taskListElevated = Color(0xFF151F2B);
  static const Color taskListSectionLabel = noteArisBlue;
  static const Color taskListTextPrimary = noteWideTextPrimary;
  static const Color taskListTextSecondary = noteWideTextSecondary;
  static const Color taskListTextMuted = noteWideTextMuted;
  static const Color taskListAccent = noteArisBlue;
  static const Color taskListAccentSky = noteArisSky;
  static const Color taskListDestructive = noteDestructive;
  static const Color taskListCompletedCheck = noteArisBlue;
  static const Color taskListChipFill = Color(0x33151F2B);
  static const Color taskListChipText = noteArisSky;
  static const Color taskListChipIcon = noteArisBlue;

  /// Calendario (v0.49.45) — coherente con Notas/Tareas en oscuro Aris.
  static const Color calendarListCanvas = noteWideCanvas;
  static const Color calendarListCardFill = noteWideSurface;
  static const Color calendarListCardExpanded = Color(0xFF131E2A);
  static const Color calendarListBorderNormal = Color(0x40243244);
  static const Color calendarListBorderSelected = Color(0x665EA8FF);
  static const Color calendarListElevated = Color(0xFF151F2B);
  static const Color calendarListSectionLabel = noteArisBlue;
  static const Color calendarListTextPrimary = noteWideTextPrimary;
  static const Color calendarListTextSecondary = noteWideTextSecondary;
  static const Color calendarListTextMuted = noteWideTextMuted;
  static const Color calendarListAccent = noteArisBlue;
  static const Color calendarListAccentSky = noteArisSky;
  static const Color calendarListDestructive = noteDestructive;
  static const Color calendarListTimelineDot = noteArisBlue;
  static const Color calendarListEventDotMuted = Color(0xFF6F7B8A);

  /// Espaciado tarjeta desplegada (v0.49.44 paso 4).
  static const double taskListExpandedPadH = 17;
  static const double taskListExpandedPadV = 15;
  static const double taskListExpandedSectionGap = 12;

  /// Sombra modo claro — tinte frío suave.
  static const Color shadowWarmLight = Color(0x33142033);

  static ColorScheme get lightScheme {
    return ColorScheme(
      brightness: Brightness.light,
      primary: brandBlueStrongLight,
      onPrimary: onPrimaryContrast,
      primaryContainer: brandBlueSurfaceLight,
      onPrimaryContainer: brandBlueDeepLight,
      secondary: secondaryViolet,
      onSecondary: onPrimaryContrast,
      secondaryContainer: brandBlueSoftLight,
      onSecondaryContainer: brandBlueDeepLight,
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
      surfaceContainerHighest: Color(0xFFE4EBF3),
      onSurfaceVariant: textSecondaryLight,
      outline: outlineLight,
      outlineVariant: outlineVariantLight,
      shadow: shadowWarmLight,
      scrim: Color(0x80000000),
      inverseSurface: surfaceDark,
      onInverseSurface: textPrimaryDark,
      inversePrimary: calendarBlueDark,
    );
  }

  /// Modo oscuro — v0.48.33: capas, bordes y acentos controlados.
  static ColorScheme get darkScheme {
    return ColorScheme(
      brightness: Brightness.dark,
      primary: calendarBlueDark,
      onPrimary: const Color(0xFF0C1624),
      primaryContainer: const Color(0xFF10243F),
      onPrimaryContainer: textPrimaryDark,
      secondary: chatAccentLavenderDark,
      onSecondary: canvasDark,
      secondaryContainer: surfaceRaisedDark,
      onSecondaryContainer: textPrimaryDark,
      tertiary: textTertiaryDark,
      onTertiary: canvasDark,
      tertiaryContainer: surfaceRaisedDark,
      onTertiaryContainer: textPrimaryDark,
      error: const Color(0xFFF2B8B5),
      onError: const Color(0xFF601410),
      errorContainer: const Color(0xFF8C1D18),
      onErrorContainer: const Color(0xFFF9DEDC),
      surface: surfaceDark,
      onSurface: textPrimaryDark,
      surfaceContainerLowest: canvasDark,
      surfaceContainerLow: surfaceContainerLowDark,
      surfaceContainer: surfaceDark,
      surfaceContainerHigh: surfaceRaisedDark,
      surfaceContainerHighest: surfaceHoverDark,
      onSurfaceVariant: textSecondaryDark,
      outline: outlineDark,
      outlineVariant: outlineVariantDark,
      shadow: Colors.black.withValues(alpha: 0.42),
      scrim: const Color(0x99000000),
      inverseSurface: surfaceLight,
      onInverseSurface: textPrimaryLight,
      inversePrimary: primaryDeep,
    );
  }
}
