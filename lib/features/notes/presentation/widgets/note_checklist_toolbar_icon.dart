import 'package:flutter/material.dart';

import 'note_toolbar_icon_style.dart';

/// Checklist: 2 círculos (primero con check) + 2 líneas (v0.49.41).
class NoteChecklistToolbarIcon extends StatelessWidget {
  const NoteChecklistToolbarIcon({
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
        painter: _NoteChecklistToolbarIconPainter(color: color),
      ),
    );
  }
}

class _NoteChecklistToolbarIconPainter extends CustomPainter {
  _NoteChecklistToolbarIconPainter({required this.color});

  final Color color;

  static const double _circleRadius = 3.6;
  static const double _lineWidth = 11;
  static const double _columnGap = 4.5;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = NoteToolbarIconStyle.stroke(color);

    const rows = [
      (cy: 9.5, checked: true),
      (cy: 18.5, checked: false),
    ];

    final circleCx = _circleRadius + 2;

    for (final row in rows) {
      final center = Offset(circleCx, row.cy);
      canvas.drawCircle(center, _circleRadius, stroke);

      if (row.checked) {
        final check = Path()
          ..moveTo(center.dx - _circleRadius * 0.5, row.cy)
          ..lineTo(center.dx - _circleRadius * 0.08, row.cy + _circleRadius * 0.52)
          ..lineTo(center.dx + _circleRadius * 0.58, row.cy - _circleRadius * 0.42);
        canvas.drawPath(check, stroke);
      }

      final lineLeft = circleCx + _circleRadius + _columnGap;
      final lineRight = lineLeft + _lineWidth;
      canvas.drawLine(
        Offset(lineLeft, row.cy),
        Offset(lineRight, row.cy),
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NoteChecklistToolbarIconPainter old) =>
      old.color != color;
}
