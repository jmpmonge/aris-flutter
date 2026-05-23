import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Dos familias de tinte press — capa detrás del texto (v0.49.78).
abstract final class PremiumPressTints {
  /// Cabeceras y tarjetas principales. [lightHue] opcional a opacidad muy baja.
  static Color accent(bool isDark, {Color? lightHue}) {
    if (isDark) {
      return AppColors.surfaceHoverDark
          .withValues(alpha: AppSpacing.pressableTintAlphaDark);
    }
    final hue = lightHue ?? const Color(0xFF64748B);
    return hue.withValues(alpha: AppSpacing.pressableTintAlphaAccentLight);
  }

  /// Filas y elementos secundarios.
  static Color neutral(bool isDark) {
    if (isDark) {
      return AppColors.surfaceHoverDark
          .withValues(alpha: AppSpacing.pressableTintAlphaDark);
    }
    return const Color(0xFF64748B)
        .withValues(alpha: AppSpacing.pressableTintAlphaNeutralLight);
  }
}

/// Micropress sobrio en tarjetas y bloques interactivos (v0.49.77).
///
/// Escala + tinte de fondo detrás del contenido (nunca encima del texto).
class PremiumPressable extends StatefulWidget {
  const PremiumPressable({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.enabled = true,
    this.pressTint,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final bool enabled;

  /// Color de fondo al pulsar; va **detrás** de [child].
  final Color? pressTint;

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

  Color? _resolvePressTint(BuildContext context) {
    if (widget.pressTint != null) return widget.pressTint;
    if (widget.borderRadius == null) return null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PremiumPressTints.neutral(isDark);
  }

  Widget _buildContent(BuildContext context) {
    final tint = _resolvePressTint(context);
    final radius = widget.borderRadius;

    if (tint == null || radius == null) return widget.child;

    return ClipRRect(
      borderRadius: radius,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: Duration(milliseconds: AppSpacing.pressableScaleMs),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: radius,
                color: _pressed ? tint : Colors.transparent,
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        child: _buildContent(context),
      ),
    );
  }
}
