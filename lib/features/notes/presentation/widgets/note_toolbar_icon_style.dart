import 'package:flutter/material.dart';

/// Estilo común de iconos de la toolbar de nota amplia (v0.49.41).
abstract final class NoteToolbarIconStyle {
  NoteToolbarIconStyle._();

  static const double size = 28;
  static const double strokeWidth = 1.9;

  static Paint stroke(Color color) {
    return Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }

  static Paint fill(Color color) {
    return Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }
}
