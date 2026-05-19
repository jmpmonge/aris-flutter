import 'package:shared_preferences/shared_preferences.dart';

/// Persistencia pista «Toca para ocultar» en tarjeta SUGERENCIA (v0.48.35).
abstract final class HomeSuggestionHintPrefs {
  static const String hintSeenKey = 'aris_home_suggestion_hint_seen';

  static Future<bool> hasSeenHint() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(hintSeenKey) ?? false;
  }

  static Future<void> markHintSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(hintSeenKey, true);
  }
}
