import 'package:flutter/material.dart';

import 'note_toolbar_icon_style.dart';

/// Marco de escaneo: 4 esquinas parciales + líneas OCR (v0.49.41).
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
  static const double _armLen = 5.0;
  static const double _cornerRadius = 1.6;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = NoteToolbarIconStyle.stroke(color);

    final left = _inset;
    final top = _inset;
    final right = size.width - _inset;
    final bottom = size.height - _inset;

    _drawCornerTopLeft(canvas, paint, left, top);
    _drawCornerTopRight(canvas, paint, right, top);
    _drawCornerBottomLeft(canvas, paint, left, bottom);
    _drawCornerBottomRight(canvas, paint, right, bottom);

    final lineLeft = left + 4.5;
    final lineRight = right - 4.5;
    final shortRight = lineLeft + (lineRight - lineLeft) * 0.52;
    final midY = (top + bottom) / 2;

    final y1 = midY - 3.2;
    final y2 = midY;
    final y3 = midY + 3.2;

    canvas.drawLine(Offset(lineLeft, y1), Offset(lineRight, y1), paint);
    canvas.drawLine(Offset(lineLeft, y2), Offset(lineRight, y2), paint);
    canvas.drawLine(Offset(lineLeft, y3), Offset(shortRight, y3), paint);
  }

  static void _drawCornerTopLeft(
    Canvas canvas,
    Paint paint,
    double left,
    double top,
  ) {
    final r = _cornerRadius;
    final path = Path()
      ..moveTo(left + _armLen, top)
      ..lineTo(left + r, top)
      ..arcToPoint(
        Offset(left, top + r),
        radius: const Radius.circular(_cornerRadius),
      )
      ..lineTo(left, top + _armLen);
    canvas.drawPath(path, paint);
  }

  static void _drawCornerTopRight(
    Canvas canvas,
    Paint paint,
    double right,
    double top,
  ) {
    final r = _cornerRadius;
    final path = Path()
      ..moveTo(right - _armLen, top)
      ..lineTo(right - r, top)
      ..arcToPoint(
        Offset(right, top + r),
        radius: const Radius.circular(_cornerRadius),
        clockwise: false,
      )
      ..lineTo(right, top + _armLen);
    canvas.drawPath(path, paint);
  }

  static void _drawCornerBottomLeft(
    Canvas canvas,
    Paint paint,
    double left,
    double bottom,
  ) {
    final r = _cornerRadius;
    final path = Path()
      ..moveTo(left + _armLen, bottom)
      ..lineTo(left + r, bottom)
      ..arcToPoint(
        Offset(left, bottom - r),
        radius: const Radius.circular(_cornerRadius),
        clockwise: false,
      )
      ..lineTo(left, bottom - _armLen);
    canvas.drawPath(path, paint);
  }

  static void _drawCornerBottomRight(
    Canvas canvas,
    Paint paint,
    double right,
    double bottom,
  ) {
    final r = _cornerRadius;
    final path = Path()
      ..moveTo(right - _armLen, bottom)
      ..lineTo(right - r, bottom)
      ..arcToPoint(
        Offset(right, bottom - r),
        radius: const Radius.circular(_cornerRadius),
      )
      ..lineTo(right, bottom - _armLen);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NoteScanToolbarIconPainter old) =>
      old.color != color;
}
