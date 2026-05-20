import 'package:flutter/material.dart';

/// Medidas de la tarjeta Aris acordeón en Home (v0.48.44-fix).
abstract final class HomeArisLayout {
  HomeArisLayout._();

  static const double messageMinHeight = 56;
  static const double messageMaxHeight = 132;
  static const int messageMaxLines = 3;
  static const double inputHeight = 44;

  /// Reserva barra de navegación inferior (~altura Material + padding).
  static const double bottomNavReserve = 56;

  /// Respiro final del scroll (no entre HOY y Aris).
  static const double scrollBottomExtra = 16;

  /// Solo al final del scroll: nav + safe area + extra.
  static double scrollBottomPadding(BuildContext context) {
    return bottomNavReserve +
        MediaQuery.paddingOf(context).bottom +
        scrollBottomExtra;
  }
}
