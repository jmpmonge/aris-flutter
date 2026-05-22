import 'package:flutter/material.dart';

import 'note_toolbar_icon_style.dart';

/// Clip inclinado hacia la derecha (v0.49.41).
class NoteAttachToolbarIcon extends StatelessWidget {
  const NoteAttachToolbarIcon({
    super.key,
    required this.color,
    this.size = NoteToolbarIconStyle.size,
  });

  final Color color;
  final double size;

  static const double _iconSize = 21;
  static const double _rotationRadians = 0.35;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Transform.rotate(
          angle: _rotationRadians,
          child: Icon(
            Icons.attach_file_rounded,
            size: _iconSize,
            color: color,
          ),
        ),
      ),
    );
  }
}
