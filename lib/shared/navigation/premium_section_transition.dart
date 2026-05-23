import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Transición fade + slide vertical mínimo entre pestañas (v0.49.77).
///
/// Mantiene todas las secciones montadas para preservar estado (scroll, etc.).
class PremiumSectionTransition extends StatefulWidget {
  const PremiumSectionTransition({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  State<PremiumSectionTransition> createState() =>
      _PremiumSectionTransitionState();
}

class _PremiumSectionTransitionState extends State<PremiumSectionTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.index;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: AppSpacing.sectionTransitionMs),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.value = 1;
  }

  @override
  void didUpdateWidget(PremiumSectionTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _previousIndex = oldWidget.index;
      _controller.forward(from: 0).whenComplete(() {
        if (mounted) {
          setState(() => _previousIndex = widget.index);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _opacityFor(int i) {
    if (!_controller.isAnimating) {
      return i == widget.index ? 1 : 0;
    }
    if (i == widget.index) return _fade.value;
    if (i == _previousIndex) return 1 - _fade.value;
    return 0;
  }

  double _slideFor(int i) {
    if (_controller.isAnimating && i == widget.index) {
      return AppSpacing.sectionTransitionSlidePx * (1 - _fade.value);
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: i != widget.index,
              child: Opacity(
                opacity: _opacityFor(i).clamp(0, 1),
                child: Transform.translate(
                  offset: Offset(0, _slideFor(i)),
                  child: widget.children[i],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
