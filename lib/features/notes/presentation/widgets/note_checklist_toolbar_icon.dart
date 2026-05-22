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

  static const double _circleRadius = 4.0;
  static const double _lineWidth = 9.5;
  static const double _columnGap = 7.0;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = NoteToolbarIconStyle.stroke(color);

    const rows = [
      (cy: 9.0, checked: true),
      (cy: 19.0, checked: false),
    ];

    final circleCx = _circleRadius + 1.6;

    for (final row in rows) {
      final center = Offset(circleCx, row.cy);
      canvas.drawCircle(center, _circleRadius, stroke);

      if (row.checked) {
        final check = Path()
          ..moveTo(center.dx - _circleRadius * 0.38, row.cy + 0.2)
          ..lineTo(center.dx - _circleRadius * 0.04, row.cy + _circleRadius * 0.3)
          ..lineTo(center.dx + _circleRadius * 0.4, row.cy - _circleRadius * 0.34);
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
