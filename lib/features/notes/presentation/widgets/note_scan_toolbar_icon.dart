import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'note_toolbar_icon_style.dart';

/// Marco de escaneo: RRect con lados cortados en el centro (v0.49.41).
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

  static const double _inset = 4.0;
  static const double _cornerRadius = 4.5;
  static const double _sideGap = 3.2;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = NoteToolbarIconStyle.stroke(color);

    final left = _inset;
    final top = _inset;
    final right = size.width - _inset;
    final bottom = size.height - _inset;
    final r = _cornerRadius;
    final midX = (left + right) / 2;
    final midY = (top + bottom) / 2;

    _drawScanFrame(
      canvas,
      paint,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      radius: r,
      midX: midX,
      midY: midY,
    );

    final lineLeft = left + 4.5;
    final lineRight = right - 4.5;
    final shortRight = lineLeft + (lineRight - lineLeft) * 0.52;

    final y1 = midY - 3.2;
    final y2 = midY;
    final y3 = midY + 3.2;

    canvas.drawLine(Offset(lineLeft, y1), Offset(lineRight, y1), paint);
    canvas.drawLine(Offset(lineLeft, y2), Offset(lineRight, y2), paint);
    canvas.drawLine(Offset(lineLeft, y3), Offset(shortRight, y3), paint);
  }

  static void _drawScanFrame(
    Canvas canvas,
    Paint paint, {
    required double left,
    required double top,
    required double right,
    required double bottom,
    required double radius,
    required double midX,
    required double midY,
  }) {
    final g = _sideGap;
    final r = radius;

    // Esquina superior izquierda
    canvas.drawArc(
      Rect.fromLTWH(left, top, 2 * r, 2 * r),
      math.pi,
      math.pi / 2,
      false,
      paint,
    );
    canvas.drawLine(Offset(left + r, top), Offset(midX - g, top), paint);
    canvas.drawLine(Offset(left, top + r), Offset(left, midY - g), paint);

    // Esquina superior derecha
    canvas.drawArc(
      Rect.fromLTWH(right - 2 * r, top, 2 * r, 2 * r),
      -math.pi / 2,
      math.pi / 2,
      false,
      paint,
    );
    canvas.drawLine(Offset(midX + g, top), Offset(right - r, top), paint);
    canvas.drawLine(Offset(right, top + r), Offset(right, midY - g), paint);

    // Esquina inferior derecha
    canvas.drawArc(
      Rect.fromLTWH(right - 2 * r, bottom - 2 * r, 2 * r, 2 * r),
      0,
      math.pi / 2,
      false,
      paint,
    );
    canvas.drawLine(Offset(right, midY + g), Offset(right, bottom - r), paint);
    canvas.drawLine(Offset(right - r, bottom), Offset(midX + g, bottom), paint);

    // Esquina inferior izquierda
    canvas.drawArc(
      Rect.fromLTWH(left, bottom - 2 * r, 2 * r, 2 * r),
      math.pi / 2,
      math.pi / 2,
      false,
      paint,
    );
    canvas.drawLine(Offset(midX - g, bottom), Offset(left + r, bottom), paint);
    canvas.drawLine(Offset(left, midY + g), Offset(left, bottom - r), paint);
  }

  @override
  bool shouldRepaint(covariant _NoteScanToolbarIconPainter old) =>
      old.color != color;
}
