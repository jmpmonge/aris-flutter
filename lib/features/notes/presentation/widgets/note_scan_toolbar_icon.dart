import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'note_toolbar_icon_style.dart';

/// Marco de escaneo con esquinas parciales redondeadas + líneas OCR (v0.49.41).
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

  static const double _cornerLen = 5.5;
  static const double _cornerRound = 1.8;
  static const double _inset = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = NoteToolbarIconStyle.stroke(color);

    final left = _inset;
    final top = _inset;
    final right = size.width - _inset;
    final bottom = size.height - _inset;

    _drawRoundedScanCorner(
      canvas,
      paint,
      corner: Offset(left, top),
      horizontalEnd: Offset(left + _cornerLen, top),
      verticalEnd: Offset(left, top + _cornerLen),
    );
    _drawRoundedScanCorner(
      canvas,
      paint,
      corner: Offset(right, top),
      horizontalEnd: Offset(right - _cornerLen, top),
      verticalEnd: Offset(right, top + _cornerLen),
    );
    _drawRoundedScanCorner(
      canvas,
      paint,
      corner: Offset(left, bottom),
      horizontalEnd: Offset(left + _cornerLen, bottom),
      verticalEnd: Offset(left, bottom - _cornerLen),
    );
    _drawRoundedScanCorner(
      canvas,
      paint,
      corner: Offset(right, bottom),
      horizontalEnd: Offset(right - _cornerLen, bottom),
      verticalEnd: Offset(right, bottom - _cornerLen),
    );

    final lineLeft = left + 5;
    final lineRight = right - 5;
    final shortRight = lineLeft + (lineRight - lineLeft) * 0.5;

    const y1 = 11.2;
    const y2 = 14.6;
    const y3 = 18.0;

    canvas.drawLine(Offset(lineLeft, y1), Offset(lineRight, y1), paint);
    canvas.drawLine(Offset(lineLeft, y2), Offset(lineRight, y2), paint);
    canvas.drawLine(Offset(lineLeft, y3), Offset(shortRight, y3), paint);
  }

  static void _drawRoundedScanCorner(
    Canvas canvas,
    Paint paint, {
    required Offset corner,
    required Offset horizontalEnd,
    required Offset verticalEnd,
  }) {
    final hx = horizontalEnd.dx - corner.dx;
    final hy = horizontalEnd.dy - corner.dy;
    final vx = verticalEnd.dx - corner.dx;
    final vy = verticalEnd.dy - corner.dy;

    final hLen = math.sqrt(hx * hx + hy * hy);
    final vLen = math.sqrt(vx * vx + vy * vy);
    if (hLen < _cornerRound + 0.5 || vLen < _cornerRound + 0.5) {
      canvas.drawLine(corner, horizontalEnd, paint);
      canvas.drawLine(corner, verticalEnd, paint);
      return;
    }

    final hUnit = Offset(hx / hLen, hy / hLen);
    final vUnit = Offset(vx / vLen, vy / vLen);
    final hStop = corner + hUnit * (hLen - _cornerRound);
    final vStop = corner + vUnit * (vLen - _cornerRound);
    final arcCenter = hStop + vUnit * _cornerRound;

    canvas.drawLine(horizontalEnd, hStop, paint);
    canvas.drawLine(verticalEnd, vStop, paint);

    final start = math.atan2(hStop.dy - arcCenter.dy, hStop.dx - arcCenter.dx);
    final end = math.atan2(vStop.dy - arcCenter.dy, vStop.dx - arcCenter.dx);
    var sweep = end - start;
    if (sweep > math.pi) sweep -= 2 * math.pi;
    if (sweep < -math.pi) sweep += 2 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: arcCenter, radius: _cornerRound),
      start,
      sweep,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _NoteScanToolbarIconPainter old) =>
      old.color != color;
}
