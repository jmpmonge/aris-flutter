import 'package:flutter/material.dart';

import 'note_toolbar_icon_style.dart';

/// Documento escaneado: marco suave + 2 líneas y media (v0.49.41).
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

  @override
  void paint(Canvas canvas, Size size) {
    final paint = NoteToolbarIconStyle.stroke(color);
    const inset = 3.5;
    const radius = 3.5;
    const innerPad = 5.0;

    final frame = RRect.fromRectAndRadius(
      Rect.fromLTWH(inset, inset, size.width - inset * 2, size.height - inset * 2),
      const Radius.circular(radius),
    );
    canvas.drawRRect(frame, paint);

    final lineLeft = inset + innerPad;
    final lineRight = size.width - inset - innerPad;
    final shortRight = lineLeft + (lineRight - lineLeft) * 0.55;

    const y1 = 11.0;
    const y2 = 15.0;
    const y3 = 19.0;

    canvas.drawLine(Offset(lineLeft, y1), Offset(lineRight, y1), paint);
    canvas.drawLine(Offset(lineLeft, y2), Offset(lineRight, y2), paint);
    canvas.drawLine(Offset(lineLeft, y3), Offset(shortRight, y3), paint);
  }

  @override
  bool shouldRepaint(covariant _NoteScanToolbarIconPainter old) =>
      old.color != color;
}
