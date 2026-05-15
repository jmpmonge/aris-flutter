import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tema global elegido por el usuario (claro / oscuro / sistema).
///
/// Persistencia: [SharedPreferences], clave `aris_theme_mode_v1`.
abstract final class ThemeService {
  static const String _prefsKey = 'aris_theme_mode_v1';

  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  static ThemeMode get current => themeMode.value;

  /// Cargar preferencia guardada. Llamar en [main] antes de [runApp].
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;
    try {
      themeMode.value = ThemeMode.values.byName(raw);
    } catch (_) {
      await prefs.remove(_prefsKey);
    }
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, mode.name);
    } catch (_) {
      // Demo: fallo de E/S no bloquea UI.
    }
  }
}
