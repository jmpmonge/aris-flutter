import 'package:flutter/material.dart';

import '../services/theme_service.dart';

/// Contrato de ajustes (tema, etc.). Hoy solo tema vía [ThemeService].
abstract interface class SettingsRepository {
  ThemeMode getThemeMode();

  ValueNotifier<ThemeMode> get themeListenable;

  Future<void> setThemeMode(ThemeMode mode);
}

final class LocalSettingsRepository implements SettingsRepository {
  @override
  ThemeMode getThemeMode() => ThemeService.current;

  @override
  ValueNotifier<ThemeMode> get themeListenable => ThemeService.themeMode;

  @override
  Future<void> setThemeMode(ThemeMode mode) => ThemeService.setThemeMode(mode);
}
