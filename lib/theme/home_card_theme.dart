import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Tokens compartidos — tarjetas Home (panel resumen + Aris).
abstract final class HomeCardTheme {
  /// Borde fino azul-grisáceo; no blanco ni outline genérico fuerte.
  static Color panelBorder(ColorScheme scheme, Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const Color(0xFF4A5C72).withValues(alpha: 0.42);
    }
    return const Color(0xFF8FA3BC).withValues(alpha: 0.28);
  }

  /// Superficie de tarjeta Aris (cuerpo + relleno + input).
  static Color arisSurface(ColorScheme scheme, Brightness brightness) {
    return brightness == Brightness.dark
        ? AppColors.surfaceRaisedDark
        : scheme.surface;
  }

  /// Flechas de navegación de sección — siempre neutras.
  static Color neutralChevron(ColorScheme scheme, Brightness brightness) {
    if (brightness == Brightness.dark) {
      return AppColors.textPrimaryDark.withValues(alpha: 0.48);
    }
    return AppColors.textTertiaryLight.withValues(alpha: 0.92);
  }

  /// Enlaces «+ X más» — información secundaria.
  static Color moreLinkText(ColorScheme scheme, Brightness brightness) {
    if (brightness == Brightness.dark) {
      return AppColors.textTertiaryDark.withValues(alpha: 0.92);
    }
    return AppColors.textSecondaryLight.withValues(alpha: 0.88);
  }

  /// Separador interno entre HOY | TAREAS | MAIL o mensaje | input.
  static Color sectionDivider(ColorScheme scheme, Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const Color(0xFF3A4A5E).withValues(alpha: 0.55);
    }
    return scheme.outline.withValues(alpha: 0.12);
  }

  static BoxDecoration cardDecoration({
    required ColorScheme scheme,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;
    return BoxDecoration(
      color: arisSurface(scheme, brightness),
      borderRadius: BorderRadius.circular(AppSpacing.homeCardRadius),
      border: Border.all(color: panelBorder(scheme, brightness), width: 1),
      boxShadow: isDark
          ? const <BoxShadow>[]
          : [
              BoxShadow(
                color: AppColors.shadowWarmLight.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
    );
  }

  /// Puntos del estado «Aris está pensando» — neutros.
  static Color thinkingDot(ColorScheme scheme, Brightness brightness) {
    if (brightness == Brightness.dark) {
      return AppColors.textTertiaryDark.withValues(alpha: 0.88);
    }
    return AppColors.textSecondaryLight.withValues(alpha: 0.78);
  }

  static TextStyle sectionTitleStyle(ColorScheme scheme, Brightness brightness) {
    return TextStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.7,
      height: 1.0,
      color: brightness == Brightness.dark
          ? AppColors.textPrimaryDark.withValues(alpha: 0.92)
          : AppColors.primaryDeep,
    );
  }
}
