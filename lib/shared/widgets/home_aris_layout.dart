/// Medidas del bloque Aris fijo en Home (v0.48.44).
abstract final class HomeArisLayout {
  HomeArisLayout._();

  /// Separador 1 + padding 9 + input 42 + padding inferior 12.
  static const double fixedInputBlockHeight = 64;

  /// Reserva visual barra de navegación inferior (~altura Material + padding).
  static const double bottomNavReserve = 56;

  /// Respiro extra para que el scroll no tape contenido.
  static const double scrollBottomExtra = 12;

  /// Padding inferior del scroll = input + nav + extra.
  static const double scrollBottomPadding =
      fixedInputBlockHeight + bottomNavReserve + scrollBottomExtra;
}
