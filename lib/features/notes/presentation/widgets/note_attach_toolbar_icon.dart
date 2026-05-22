import 'package:flutter/material.dart';

/// Clip inclinado — `attach_file_rounded` rotado (referencia v0.49.41).
class NoteAttachToolbarIcon extends StatelessWidget {
  const NoteAttachToolbarIcon({
    super.key,
    required this.color,
    this.size = 28,
  });

  final Color color;
  final double size;

  static const double _iconSize = 22;
  static const double _rotationRadians = -0.45;

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
