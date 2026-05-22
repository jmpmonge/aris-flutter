import 'package:flutter/material.dart';

/// Checklist toolbar: 2 círculos + 2 líneas (referencia v0.49.41).
class NoteChecklistToolbarIcon extends StatelessWidget {
  const NoteChecklistToolbarIcon({
    super.key,
    required this.color,
    this.size = 28,
  });

  final Color color;
  final double size;

  static const double _circleSize = 5;
  static const double _lineWidth = 14;
  static const double _lineHeight = 2;
  static const double _columnGap = 5;
  static const double _rowGap = 7;
  static const double _strokeWidth = 1.5;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ChecklistToolbarRow(color: color),
            const SizedBox(height: _rowGap),
            _ChecklistToolbarRow(color: color),
          ],
        ),
      ),
    );
  }
}

class _ChecklistToolbarRow extends StatelessWidget {
  const _ChecklistToolbarRow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: NoteChecklistToolbarIcon._circleSize,
          height: NoteChecklistToolbarIcon._circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: NoteChecklistToolbarIcon._strokeWidth,
            ),
          ),
        ),
        const SizedBox(width: NoteChecklistToolbarIcon._columnGap),
        Container(
          width: NoteChecklistToolbarIcon._lineWidth,
          height: NoteChecklistToolbarIcon._lineHeight,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}
