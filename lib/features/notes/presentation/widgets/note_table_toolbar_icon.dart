import 'package:flutter/material.dart';

import 'note_toolbar_icon_style.dart';

/// Tabla 2×3, proporción horizontal (v0.49.41).
class NoteTableToolbarIcon extends StatelessWidget {
  const NoteTableToolbarIcon({
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
        painter: _NoteTableToolbarIconPainter(color: color),
      ),
    );
  }
}

class _NoteTableToolbarIconPainter extends CustomPainter {
  _NoteTableToolbarIconPainter({required this.color});

  final Color color;

  static const double _tableWidth = 26;
  static const double _tableHeight = 18;
  static const double _radius = 3.5;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = NoteToolbarIconStyle.stroke(color);

    final left = (size.width - _tableWidth) / 2;
    final top = (size.height - _tableHeight) / 2;
    final right = left + _tableWidth;
    final bottom = top + _tableHeight;

    final outer = RRect.fromRectAndRadius(
      Rect.fromLTRB(left, top, right, bottom),
      const Radius.circular(_radius),
    );
    canvas.drawRRect(outer, paint);

    final midX = (left + right) / 2;
    final row1Y = top + _tableHeight / 3;
    final row2Y = top + _tableHeight * 2 / 3;

    canvas.drawLine(Offset(midX, top), Offset(midX, bottom), paint);
    canvas.drawLine(Offset(left, row1Y), Offset(right, row1Y), paint);
    canvas.drawLine(Offset(left, row2Y), Offset(right, row2Y), paint);
  }

  @override
  bool shouldRepaint(covariant _NoteTableToolbarIconPainter old) =>
      old.color != color;
}
