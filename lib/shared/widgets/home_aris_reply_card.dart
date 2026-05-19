import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Mensaje demo de intervención activa (v0.48.43).
const String kHomeArisDefaultActiveMessage =
    'He visto que tienes dos eventos esta tarde.\n'
    '¿Quieres que te avise 15 min antes del primero?';

/// Tarjeta compacta Aris en Home: una intervención + input encapsulado (v0.48.43).
class HomeArisReplyCard extends StatefulWidget {
  const HomeArisReplyCard({
    super.key,
    this.activeMessage = kHomeArisDefaultActiveMessage,
    this.isSending = false,
    this.onTapCard,
    this.onSubmitted,
    this.onMicPressed,
  });

  final String activeMessage;
  final bool isSending;
  final VoidCallback? onTapCard;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onMicPressed;

  @override
  State<HomeArisReplyCard> createState() => _HomeArisReplyCardState();
}

class _HomeArisReplyCardState extends State<HomeArisReplyCard> {
  final _controller = TextEditingController();

  static const double _cardRadius = AppSpacing.homeCardRadius;
  static const double _padH = 16;
  static const double _padV = 15;
  static const double _inputHeight = 42;
  static const double _inputRadius = 20;
  static const double _inputPadH = 13;
  static const double _micSize = 36;
  static const double _micIconSize = 21;

  static const Color _kArisTitleLight = Color(0xFF6B4FCF);
  static const Color _kArisTitleDark = AppColors.chatAccentLavenderDark;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  bool get _hasText => _controller.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final arisTitleColor = isDark ? _kArisTitleDark : _kArisTitleLight;

    final activePillBg = isDark
        ? AppColors.suggestionGreenDark.withValues(alpha: 0.14)
        : AppColors.success.withValues(alpha: 0.12);
    final activePillFg = isDark
        ? AppColors.suggestionGreenDark.withValues(alpha: 0.92)
        : AppColors.success.withValues(alpha: 0.88);

    final dividerColor = isDark
        ? scheme.outlineVariant.withValues(alpha: 0.28)
        : scheme.outline.withValues(alpha: 0.15);

    final inputBg = isDark
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.55)
        : scheme.surfaceContainerHigh.withValues(alpha: 0.65);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.homePageMarginH),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(_cardRadius),
          border: Border.all(
            color: scheme.outline.withValues(
              alpha: AppColors.homeCardBorderAlpha(
                isDark ? Brightness.dark : Brightness.light,
              ),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(
                alpha: AppColors.homeCardShadowAlpha(
                  isDark ? Brightness.dark : Brightness.light,
                ),
              ),
              blurRadius: AppSpacing.shadowBlurHomeCard,
              offset: AppSpacing.shadowOffsetHomeCard,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _padH,
            vertical: _padV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTapCard,
                  borderRadius: BorderRadius.circular(
                    AppSpacing.homeCardHeaderInkBorderRadius,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'ARIS',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                height: 1.0,
                                color: arisTitleColor,
                              ),
                            ),
                            const Spacer(),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: activePillBg,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 3.5,
                                ),
                                child: Text(
                                  'Activo',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    height: 1.0,
                                    color: activePillFg,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.activeMessage,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.5,
                            height: 1.32,
                            fontWeight: FontWeight.w400,
                            color: scheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 13, bottom: 9),
                child: Divider(height: 1, thickness: 1, color: dividerColor),
              ),
              SizedBox(
                height: _inputHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(_inputRadius),
                          border: Border.all(
                            color: scheme.outline.withValues(alpha: 0.12),
                          ),
                        ),
                        child: TextField(
                          controller: _controller,
                          enabled: !widget.isSending,
                          textInputAction: TextInputAction.send,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.25,
                            color: scheme.onSurface,
                          ),
                          onSubmitted: (value) {
                            final t = value.trim();
                            if (t.isEmpty || widget.isSending) return;
                            widget.onSubmitted?.call(t);
                            _controller.clear();
                          },
                          decoration: InputDecoration(
                            hintText: 'Escribe a Aris…',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              height: 1.25,
                              color: scheme.onSurfaceVariant.withValues(
                                alpha: 0.72,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: _inputPadH,
                              vertical: 10,
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTrailingAction(scheme, isDark, arisTitleColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrailingAction(
    ColorScheme scheme,
    bool isDark,
    Color arisAccent,
  ) {
    if (_hasText) {
      return SizedBox(
        width: _micSize,
        height: _micSize,
        child: FilledButton(
          onPressed: widget.isSending
              ? null
              : () {
                  final t = _controller.text.trim();
                  if (t.isEmpty) return;
                  widget.onSubmitted?.call(t);
                  _controller.clear();
                },
          style: FilledButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
            minimumSize: const Size(_micSize, _micSize),
            maximumSize: const Size(_micSize, _micSize),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: widget.isSending
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: scheme.onPrimary,
                  ),
                )
              : Icon(
                  Icons.send_rounded,
                  size: 20,
                  color: scheme.onPrimary,
                ),
        ),
      );
    }

    return Material(
      color: isDark
          ? const Color(0xFF303746)
          : scheme.secondaryContainer.withValues(alpha: 0.65),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: widget.isSending ? null : widget.onMicPressed,
        child: SizedBox(
          width: _micSize,
          height: _micSize,
          child: Icon(
            Icons.mic_none_rounded,
            size: _micIconSize,
            color: isDark
                ? scheme.onSurface.withValues(alpha: 0.88)
                : arisAccent.withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }
}
