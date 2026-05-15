import 'package:flutter/material.dart';

/// Preferencia de apariencia de Aris (persistible como [ThemeMode.name]).
///
/// Mapeo directo con [ThemeMode]: `light` · `dark` · `system`.
enum AppThemePreference {
  light,
  dark,
  system;

  ThemeMode get asThemeMode => ThemeMode.values.byName(name);

  static AppThemePreference fromThemeMode(ThemeMode mode) =>
      AppThemePreference.values.byName(mode.name);

  String get labelEs => switch (this) {
        AppThemePreference.light => 'Claro',
        AppThemePreference.dark => 'Oscuro',
        AppThemePreference.system => 'Sistema',
      };
}
