import 'package:flutter/material.dart';

/// Icono toolbar: círculos vacíos + líneas (no checklist inclinado).
class NoteChecklistToolbarIcon extends StatelessWidget {
  const NoteChecklistToolbarIcon({
    super.key,
    required this.color,
    this.size = 22,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _NoteChecklistToolbarIconPainter(color: color),
      ),
    );
  }
}

class _NoteChecklistToolbarIconPainter extends CustomPainter {
  _NoteChecklistToolbarIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    const rows = 3;
    final rowH = size.height / (rows + 0.5);
    final r = size.width * 0.11;
    final cx = r + 1;
    final lineLeft = cx + r + 2.5;
    final lineRight = size.width - 1;

    for (var i = 0; i < rows; i++) {
      final cy = rowH * (i + 0.85);
      canvas.drawCircle(Offset(cx, cy), r, paint);
      canvas.drawLine(
        Offset(lineLeft, cy),
        Offset(lineRight, cy),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NoteChecklistToolbarIconPainter old) =>
      old.color != color;
}
