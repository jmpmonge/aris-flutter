/// Puntos de ruptura orientativos; la UI avanzada se definirá en fases posteriores.
abstract final class LayoutBreakpoints {
  static const double narrowMaxWidth = 600;

  /// Ancho máximo del marco tipo **iPhone** en Flutter Web (clase ~14 Pro Max).
  static const double webMobileFrameMaxWidth = 430;

  /// Márgenes exteriores del marco en web ancha (desktop / tablet landscape).
  static const double webFrameOuterPaddingH = 20;
  static const double webFrameOuterPaddingV = 16;

  /// Radio exterior del “dispositivo” simulado en web.
  static const double webFrameBorderRadius = 28;
}
