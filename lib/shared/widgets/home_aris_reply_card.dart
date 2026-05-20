import 'package:flutter/material.dart';

import 'aris_thinking_indicator.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/home_card_theme.dart';

/// Overlay cabecera ARIS.
WidgetStateProperty<Color?> _arisHeaderOverlayColor(bool isDark) {
  const light = Color(0xFFF0EEFF);
  const lightHover = Color(0xFFEDE9FF);
  return WidgetStateProperty.resolveWith((states) {
    if (isDark) {
      if (states.contains(WidgetState.pressed)) {
        return AppColors.surfaceHoverDark.withValues(alpha: 0.96);
      }
      if (states.contains(WidgetState.hovered) ||
          states.contains(WidgetState.focused)) {
        return AppColors.surfaceRaisedDark.withValues(alpha: 0.92);
      }
      return Colors.transparent;
    }
    if (states.contains(WidgetState.pressed)) {
      return light.withValues(alpha: 0.92);
    }
    if (states.contains(WidgetState.hovered) ||
        states.contains(WidgetState.focused)) {
      return lightHover.withValues(alpha: 0.72);
    }
    return Colors.transparent;
  });
}

/// Tarjeta Aris unificada: header + mensaje colapsable + input fijo (v0.48.48).
class HomeArisDockCard extends StatefulWidget {
  const HomeArisDockCard({
    super.key,
    required this.messageExpanded,
    required this.activeMessage,
    required this.isSending,
    this.onOpenFullConversation,
    this.onSubmit,
    this.onMicPressed,
  });

  final bool messageExpanded;
  final String activeMessage;
  final bool isSending;
  final VoidCallback? onOpenFullConversation;
  final Future<void> Function(String text)? onSubmit;
  final VoidCallback? onMicPressed;

  static const double _padH = 16;
  static const double _padTop = 15;
  static const double _padBottom = 12;
  static const double _messageGap = 12;
  static const double _messageHeight = 58;
  static const double _inputHeight = 42;
  static const double _inputRadius = 20;
  static const double _inputPadH = 13;
  static const double _micSize = 36;
  static const double _micIconSize = 21;
  static const double _inputTopGap = 9;

  /// Bloque mensaje (solo expandido).
  static const double messageBlockHeight = _messageGap + _messageHeight;

  /// Altura mínima colapsada: header + separador + input.
  static const double dockHeightCollapsed =
      _padTop + 36 + _inputTopGap + 1 + _inputHeight + _padBottom;

  /// Referencia histórica para métricas de layout.
  static const double dockHeight = dockHeightCollapsed;

  static const Color _kArisTitleDark = AppColors.chatAccentLavenderDark;

  static const Duration _bodyAnimationDuration = Duration(milliseconds: 200);

  @override
  State<HomeArisDockCard> createState() => _HomeArisDockCardState();
}

class _HomeArisDockCardState extends State<HomeArisDockCard> {
  final _controller = TextEditingController();

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

  Future<void> _handleSubmit(String raw) async {
    final t = raw.trim();
    if (t.isEmpty || widget.isSending) return;
    _controller.clear();
    await widget.onSubmit?.call(t);
  }

  Widget _buildArisHeaderRow({
    required ColorScheme scheme,
    required bool isDark,
    required Color arisIconColor,
  }) {
    final titleStyle = HomeCardTheme.sectionTitleStyle(
      scheme,
      isDark ? Brightness.dark : Brightness.light,
    );

    final chevronColor = HomeCardTheme.neutralChevron(
      scheme,
      isDark ? Brightness.dark : Brightness.light,
    );

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.auto_awesome_rounded,
          size: AppSpacing.homeCardHeaderIconSize,
          color: arisIconColor,
        ),
        const SizedBox(width: AppSpacing.homeCardHeaderIconTitleGap),
        Expanded(child: Text('ARIS', style: titleStyle)),
        if (widget.onOpenFullConversation != null)
          SizedBox(
            width: AppSpacing.homeCardHeaderChevronBox,
            height: AppSpacing.homeCardHeaderChevronBox,
            child: Center(
              child: Icon(
                Icons.chevron_right_rounded,
                size: AppSpacing.homeCardHeaderChevronSize,
                color: chevronColor,
              ),
            ),
          ),
      ],
    );

    final padded = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.homeCardHeaderInkPaddingH,
        vertical: AppSpacing.homeCardHeaderInkPaddingV,
      ),
      child: row,
    );

    if (widget.onOpenFullConversation == null) return padded;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onOpenFullConversation,
        borderRadius: BorderRadius.circular(
          AppSpacing.homeCardHeaderInkBorderRadius,
        ),
        overlayColor: _arisHeaderOverlayColor(isDark),
        child: padded,
      ),
    );
  }

  Widget _buildMessage({
    required ColorScheme scheme,
    required bool isDark,
    required Brightness brightness,
  }) {
    return SizedBox(
      height: HomeArisDockCard._messageHeight,
      child: Align(
        alignment: Alignment.centerLeft,
        child: widget.isSending
            ? ArisThinkingIndicator(
                compact: true,
                dotColor: HomeCardTheme.thinkingDot(scheme, brightness),
                textStyle: TextStyle(
                  fontSize: 14.5,
                  height: 1.32,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                  color: isDark
                      ? AppColors.textSecondaryDark.withValues(alpha: 0.92)
                      : AppColors.textSecondaryLight,
                ),
              )
            : Text(
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
        width: HomeArisDockCard._micSize,
        height: HomeArisDockCard._micSize,
        child: FilledButton(
          onPressed: widget.isSending
              ? null
              : () => _handleSubmit(_controller.text),
          style: FilledButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
            minimumSize: const Size(
              HomeArisDockCard._micSize,
              HomeArisDockCard._micSize,
            ),
            maximumSize: const Size(
              HomeArisDockCard._micSize,
              HomeArisDockCard._micSize,
            ),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Icon(
            Icons.send_rounded,
            size: 20,
            color: scheme.onPrimary.withValues(
              alpha: widget.isSending ? 0.45 : 1,
            ),
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
          width: HomeArisDockCard._micSize,
          height: HomeArisDockCard._micSize,
          child: Icon(
            Icons.mic_none_rounded,
            size: HomeArisDockCard._micIconSize,
            color: isDark
                ? scheme.onSurface.withValues(alpha: 0.88)
                : arisAccent.withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final arisIconColor =
        isDark ? HomeArisDockCard._kArisTitleDark : AppColors.secondaryViolet;
    final arisAccent =
        isDark ? HomeArisDockCard._kArisTitleDark : AppColors.secondaryViolet;
    final dividerColor = HomeCardTheme.sectionDivider(scheme, brightness);

    final inputBg = isDark
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.55)
        : scheme.surfaceContainerHigh.withValues(alpha: 0.65);

    final cardRadius = BorderRadius.circular(AppSpacing.homeCardRadius);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.homePageMarginH),
      child: ClipRRect(
        borderRadius: cardRadius,
        child: DecoratedBox(
          decoration: HomeCardTheme.cardDecoration(
            scheme: scheme,
            brightness: brightness,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              HomeArisDockCard._padH,
              HomeArisDockCard._padTop,
              HomeArisDockCard._padH,
              HomeArisDockCard._padBottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildArisHeaderRow(
                  scheme: scheme,
                  isDark: isDark,
                  arisIconColor: arisIconColor,
                ),
                AnimatedSize(
                  duration: HomeArisDockCard._bodyAnimationDuration,
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: widget.messageExpanded
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: HomeArisDockCard._messageGap),
                            _buildMessage(
                              scheme: scheme,
                              isDark: isDark,
                              brightness: brightness,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                Divider(height: 1, thickness: 1, color: dividerColor),
                const SizedBox(height: HomeArisDockCard._inputTopGap),
                SizedBox(
                  height: HomeArisDockCard._inputHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(
                              HomeArisDockCard._inputRadius,
                            ),
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
                            onSubmitted: _handleSubmit,
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
                                horizontal: HomeArisDockCard._inputPadH,
                                vertical: 10,
                              ),
                              isDense: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildTrailingAction(scheme, isDark, arisAccent),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
