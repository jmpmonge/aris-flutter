import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Tema global Aris: **claro y oscuro**, tarjetas con sombra suave, FAB circular.
abstract final class AppTheme {
  /// Alias explícitos para [MaterialApp.theme] / [MaterialApp.darkTheme].
  static ThemeData get lightTheme => light();

  static ThemeData get darkTheme => dark();

  static ThemeData light() => _build(
    scheme: AppColors.lightScheme,
    scaffoldMuted: AppColors.canvasLight,
    cardElevation: AppSpacing.cardElevationLight,
  );

  static ThemeData dark() => _build(
    scheme: AppColors.darkScheme,
    scaffoldMuted: AppColors.canvasDark,
    cardElevation: AppSpacing.cardElevationDark,
  );

  static ThemeData _build({
    required ColorScheme scheme,
    required Color scaffoldMuted,
    required double cardElevation,
  }) {
    final text = AppTypography.textTheme(scheme);
    final isLight = scheme.brightness == Brightness.light;
    final borderAlpha = isLight ? 0.28 : 0.4;

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldMuted,
      textTheme: text,
      dividerColor: scheme.outlineVariant,
      splashFactory: InkRipple.splashFactory,
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: scheme.primary.withValues(
          alpha: isLight ? 0.06 : 0.08,
        ),
        elevation: cardElevation,
        shadowColor: scheme.shadow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(
            color: scheme.outline.withValues(alpha: borderAlpha),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: scaffoldMuted,
        foregroundColor: scheme.onSurface,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: scheme.onSurface, size: 22),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        hintStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(
            color: scheme.primary.withValues(alpha: 0.55),
            width: 1.5,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: AppSpacing.homeNavBarHeight,
        elevation: 0,
        backgroundColor: scheme.surface,
        indicatorColor: isLight
            ? scheme.secondaryContainer.withValues(alpha: 0.88)
            : const Color(0xFF303746).withValues(alpha: 0.88),
        surfaceTintColor: Colors.transparent,
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (isLight) return null;
          if (states.contains(WidgetState.pressed)) {
            return const Color(0xFF303746).withValues(alpha: 0.45);
          }
          return null;
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return text.labelSmall?.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
            fontSize: 11.5,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: AppSpacing.homeNavIconSize,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 4,
        focusElevation: 4,
        hoverElevation: 6,
        highlightElevation: 6,
        sizeConstraints: BoxConstraints.tightFor(
          width: AppSpacing.homeFabDiameter,
          height: AppSpacing.homeFabDiameter,
        ),
        smallSizeConstraints: BoxConstraints.tightFor(
          width: AppSpacing.homeFabDiameter,
          height: AppSpacing.homeFabDiameter,
        ),
        shape: const CircleBorder(),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(
            const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          iconColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return scheme.onSurface.withValues(alpha: 0.38);
            }
            return scheme.onSurfaceVariant;
          }),
          overlayColor: isLight
              ? null
              : WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return const Color(0xFF303746).withValues(alpha: 0.5);
                  }
                  return null;
                }),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: isLight
            ? null
            : SegmentedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: const Color(0xFFC3CAD6),
                selectedForegroundColor: const Color(0xFFE8ECF4),
                selectedBackgroundColor: const Color(0xFF263044),
                side: const BorderSide(
                  color: Color(0xFF3A4354),
                  width: 1,
                ),
              ),
      ),
    );
  }
}
