import 'package:flutter/material.dart';

import 'note_toolbar_icon_style.dart';

/// Marco de escaneo con esquinas parciales + líneas OCR (v0.49.41).
class NoteScanToolbarIcon extends StatelessWidget {
  const NoteScanToolbarIcon({
    super.key,
    required this.color,
    this.size = NoteToolbarIconStyle.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _NoteScanToolbarIconPainter(color: color),
      ),
    );
  }
}

class _NoteScanToolbarIconPainter extends CustomPainter {
  _NoteScanToolbarIconPainter({required this.color});

  final Color color;

  static const double _cornerLen = 5.0;
  static const double _inset = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = NoteToolbarIconStyle.stroke(color);

    final left = _inset;
    final top = _inset;
    final right = size.width - _inset;
    final bottom = size.height - _inset;

    _drawScanCorners(
      canvas,
      paint,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      len: _cornerLen,
    );

    final lineLeft = left + 5;
    final lineRight = right - 5;
    final shortRight = lineLeft + (lineRight - lineLeft) * 0.52;

    const y1 = 11.0;
    const y2 = 14.8;
    const y3 = 18.6;

    canvas.drawLine(Offset(lineLeft, y1), Offset(lineRight, y1), paint);
    canvas.drawLine(Offset(lineLeft, y2), Offset(lineRight, y2), paint);
    canvas.drawLine(Offset(lineLeft, y3), Offset(shortRight, y3), paint);
  }

  static void _drawScanCorners(
    Canvas canvas,
    Paint paint, {
    required double left,
    required double top,
    required double right,
    required double bottom,
    required double len,
  }) {
    // Superior izquierda
    canvas.drawLine(Offset(left, top), Offset(left + len, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left, top + len), paint);
    // Superior derecha
    canvas.drawLine(Offset(right - len, top), Offset(right, top), paint);
    canvas.drawLine(Offset(right, top), Offset(right, top + len), paint);
    // Inferior izquierda
    canvas.drawLine(Offset(left, bottom - len), Offset(left, bottom), paint);
    canvas.drawLine(Offset(left, bottom), Offset(left + len, bottom), paint);
    // Inferior derecha
    canvas.drawLine(Offset(right, bottom - len), Offset(right, bottom), paint);
    canvas.drawLine(Offset(right - len, bottom), Offset(right, bottom), paint);
  }

  @override
  bool shouldRepaint(covariant _NoteScanToolbarIconPainter old) =>
      old.color != color;
}
