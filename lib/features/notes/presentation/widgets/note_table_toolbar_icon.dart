import 'package:flutter/material.dart';

import 'note_toolbar_icon_style.dart';

/// Rejilla 3×2 suave (v0.49.41).
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

  @override
  void paint(Canvas canvas, Size size) {
    final paint = NoteToolbarIconStyle.stroke(color);
    const inset = 4.0;
    const radius = 3.0;

    final outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(inset, inset, size.width - inset * 2, size.height - inset * 2),
      const Radius.circular(radius),
    );
    canvas.drawRRect(outer, paint);

    final left = inset;
    final right = size.width - inset;
    final top = inset;
    final bottom = size.height - inset;
    final midX = (left + right) / 2;
    final row1Y = top + (bottom - top) / 3;
    final row2Y = top + (bottom - top) * 2 / 3;

    canvas.drawLine(Offset(midX, top), Offset(midX, bottom), paint);
    canvas.drawLine(Offset(left, row1Y), Offset(right, row1Y), paint);
    canvas.drawLine(Offset(left, row2Y), Offset(right, row2Y), paint);
  }

  @override
  bool shouldRepaint(covariant _NoteTableToolbarIconPainter old) =>
      old.color != color;
}
