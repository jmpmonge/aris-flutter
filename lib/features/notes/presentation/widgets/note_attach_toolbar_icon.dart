import 'package:flutter/material.dart';

/// Clip inclinado fino para la toolbar de nota amplia.
class NoteAttachToolbarIcon extends StatelessWidget {
  const NoteAttachToolbarIcon({
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
        painter: _NoteAttachToolbarIconPainter(color: color),
      ),
    );
  }
}

class _NoteAttachToolbarIconPainter extends CustomPainter {
  _NoteAttachToolbarIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.22, h * 0.78)
      ..quadraticBezierTo(w * 0.08, h * 0.42, w * 0.34, h * 0.24)
      ..quadraticBezierTo(w * 0.58, h * 0.1, w * 0.72, h * 0.3)
      ..quadraticBezierTo(w * 0.86, h * 0.5, w * 0.68, h * 0.66)
      ..quadraticBezierTo(w * 0.5, h * 0.82, w * 0.36, h * 0.7)
      ..quadraticBezierTo(w * 0.24, h * 0.6, w * 0.3, h * 0.48)
      ..quadraticBezierTo(w * 0.38, h * 0.34, w * 0.52, h * 0.32);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NoteAttachToolbarIconPainter old) =>
      old.color != color;
}
