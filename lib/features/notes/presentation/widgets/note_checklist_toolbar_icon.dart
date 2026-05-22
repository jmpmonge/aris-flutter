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

    const rows = 2;
    final r = size.width * 0.1;
    final cx = r + 1.2;
    final lineLeft = cx + r + 2.5;
    final lineRight = size.width - 1;
    final centers = [size.height * 0.38, size.height * 0.68];

    for (var i = 0; i < rows; i++) {
      final cy = centers[i];
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
