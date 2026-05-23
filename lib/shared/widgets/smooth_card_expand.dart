import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Despliegue suave sin rebote para tarjetas expandibles (v0.49.76).
class SmoothCardExpandReveal extends StatelessWidget {
  const SmoothCardExpandReveal({
    super.key,
    required this.isExpanded,
    required this.child,
    this.animateSize = true,
  });

  final bool isExpanded;
  final Widget child;

  /// Si es false, el contenido aparece/desaparece sin AnimatedSize (v0.49.84).
  final bool animateSize;

  static Duration get _sizeDuration =>
      Duration(milliseconds: AppSpacing.cardExpandSizeMs);
  static Duration get _fadeDuration =>
      Duration(milliseconds: AppSpacing.cardExpandFadeMs);

  @override
  Widget build(BuildContext context) {
    if (!animateSize) {
      if (!isExpanded) {
        return const SizedBox(width: double.infinity, height: 0);
      }
      return child;
    }

    return AnimatedSize(
      duration: _sizeDuration,
      curve: isExpanded ? Curves.easeOutCubic : Curves.easeInOutCubic,
      alignment: Alignment.topCenter,
      clipBehavior: Clip.hardEdge,
      child: isExpanded
          ? TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: _fadeDuration,
              curve: Curves.easeOutCubic,
              builder: (context, t, expandedChild) {
                return Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      AppSpacing.cardExpandContentSlide * (1 - t),
                    ),
                    child: expandedChild,
                  ),
                );
              },
              child: child,
            )
          : const SizedBox(width: double.infinity, height: 0),
    );
  }
}

/// Chevron con rotación suave al expandir/contraer (v0.49.76).
class SmoothCardExpandChevron extends StatelessWidget {
  const SmoothCardExpandChevron({
    super.key,
    required this.isExpanded,
    this.color,
    this.size = 20,
  });

  final bool isExpanded;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: isExpanded ? 0.5 : 0.0,
      duration: Duration(milliseconds: AppSpacing.cardExpandChevronMs),
      curve: Curves.easeInOutCubic,
      child: Icon(
        Icons.expand_more_rounded,
        size: size,
        color: color,
      ),
    );
  }
}
