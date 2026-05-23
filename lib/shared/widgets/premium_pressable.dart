import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Micropress sobrio en tarjetas y bloques interactivos (v0.49.77).
class PremiumPressable extends StatefulWidget {
  const PremiumPressable({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.enabled = true,
    this.overlayColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final bool enabled;
  final WidgetStateProperty<Color?>? overlayColor;

  @override
  State<PremiumPressable> createState() => _PremiumPressableState();
}

class _PremiumPressableState extends State<PremiumPressable> {
  bool _pressed = false;

  bool get _interactive => widget.enabled && widget.onTap != null;

  void _setPressed(bool value) {
    if (!_interactive || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? BorderRadius.zero;

    Widget content = widget.child;

    if (widget.overlayColor != null) {
      final overlay = widget.overlayColor!.resolve(
        _pressed ? {WidgetState.pressed} : {},
      );
      content = ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            content,
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _pressed && overlay != null ? 1 : 0,
                  duration:
                      Duration(milliseconds: AppSpacing.pressableScaleMs),
                  curve: Curves.easeOutCubic,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      color: overlay,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _interactive ? (_) => _setPressed(true) : null,
      onTapUp: _interactive
          ? (_) {
              _setPressed(false);
              widget.onTap!();
            }
          : null,
      onTapCancel: _interactive ? () => _setPressed(false) : null,
      child: AnimatedScale(
        scale: _pressed ? AppSpacing.pressableScale : 1,
        duration: Duration(milliseconds: AppSpacing.pressableScaleMs),
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        child: content,
      ),
    );
  }
}
