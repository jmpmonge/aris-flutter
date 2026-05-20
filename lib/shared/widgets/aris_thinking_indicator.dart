import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/home_card_theme.dart';

/// Texto estándar mientras Aris espera respuesta de GPT.
const String kArisThinkingMessage = 'Aris está pensando';

/// Indicador discreto: texto + tres puntos animados (v0.48.44).
class ArisThinkingIndicator extends StatefulWidget {
  const ArisThinkingIndicator({
    super.key,
    this.textStyle,
    this.dotColor,
    this.compact = false,
  });

  final TextStyle? textStyle;
  final Color? dotColor;
  final bool compact;

  @override
  State<ArisThinkingIndicator> createState() => _ArisThinkingIndicatorState();
}

class _ArisThinkingIndicatorState extends State<ArisThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final dotColor = widget.dotColor ??
        HomeCardTheme.thinkingDot(scheme, brightness);
    final textStyle = widget.textStyle ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : scheme.onSurfaceVariant,
              height: 1.35,
              fontStyle: FontStyle.italic,
              fontSize: widget.compact ? 14 : null,
            );

    final dotSize = widget.compact ? 4.0 : 5.0;
    final gap = widget.compact ? 3.0 : 4.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(kArisThinkingMessage, style: textStyle),
        const SizedBox(width: 2),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(3, (i) {
                final phase = (_controller.value * 3 + i) % 3;
                final opacity = phase < 1 ? 0.35 + phase * 0.55 : 0.9 - (phase - 1) * 0.4;
                return Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : gap),
                  child: Opacity(
                    opacity: opacity.clamp(0.35, 1.0),
                    child: Container(
                      width: dotSize,
                      height: dotSize,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

/// Burbuja placeholder de Aris mientras llega la respuesta (altura estable).
class ArisThinkingBubble extends StatelessWidget {
  const ArisThinkingBubble({
    super.key,
    required this.scheme,
    required this.textTheme,
    this.minHeight = 52,
  });

  final ColorScheme scheme;
  final TextTheme textTheme;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleBackground =
        isDark ? AppColors.surfaceRaisedDark : AppColors.softBlue;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: minHeight,
          maxWidth: AppSpacing.chatBubbleMaxWidth,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: bubbleBackground,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSpacing.radiusMd),
              topRight: Radius.circular(AppSpacing.radiusMd),
              bottomRight: Radius.circular(AppSpacing.radiusMd),
              bottomLeft: Radius.circular(AppSpacing.radiusTail),
            ),
            border: Border.all(
              color: isDark
                  ? AppColors.outlineVariantDark.withValues(alpha: 0.55)
                  : scheme.outline.withValues(alpha: 0.16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ARIS',
                style: textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.8,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.primaryDeep,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              const ArisThinkingIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
