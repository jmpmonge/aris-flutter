import 'package:flutter/foundation.dart';

/// Estado de sesión del saludo temporal de Home (v0.49.34).
///
/// Evita repetir la animación al cambiar de pestaña dentro de la misma
/// instancia. Preparado para extender con preferencias diarias en el futuro.
abstract final class HomeGreetingSession {
  static bool _compactModeReached = false;

  static bool get hasReachedCompactMode => _compactModeReached;

  /// Notifica cuando la cabecera pasa a modo compacto (ajuste ListView).
  static final ValueNotifier<bool> compactModeListenable = ValueNotifier(false);

  /// Progreso de colapso 0→1 para sincronizar padding ListView con cabecera.
  static final ValueNotifier<double> collapseProgress = ValueNotifier(0);

  static void markCompactReached() {
    _compactModeReached = true;
    collapseProgress.value = 1;
    compactModeListenable.value = true;
  }

  /// Solo para pruebas o reset de sesión.
  static void resetForTesting() {
    _compactModeReached = false;
    collapseProgress.value = 0;
    compactModeListenable.value = false;
  }
}
