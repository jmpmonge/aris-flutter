import 'package:flutter/material.dart';

import 'aris_thinking_indicator.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/home_card_theme.dart';

/// Overlay cabecera ARIS — igual que CHAT CON ARIS (v0.48.33).
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

/// Tarjeta Aris en scroll — cabecera + mensaje (v0.48.49).
class HomeArisReplyCard extends StatelessWidget {
  const HomeArisReplyCard({
    super.key,
    required this.activeMessage,
    this.isSending = false,
    this.onOpenFullConversation,
  });

  final String activeMessage;
  final bool isSending;
  final VoidCallback? onOpenFullConversation;

  static const double _padH = 16;
  static const double _padV = 15;

  /// Altura de referencia para métricas de layout en Home.
  static const double bodyHeight = _padV * 2 + 36 + 12 + 58;

  static const Color _kArisTitleDark = AppColors.chatAccentLavenderDark;

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
        if (onOpenFullConversation != null)
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

    if (onOpenFullConversation == null) return padded;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpenFullConversation,
        borderRadius: BorderRadius.circular(
          AppSpacing.homeCardHeaderInkBorderRadius,
        ),
        overlayColor: _arisHeaderOverlayColor(isDark),
        child: padded,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final arisIconColor =
        isDark ? _kArisTitleDark : AppColors.secondaryViolet;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.homePageMarginH),
      child: DecoratedBox(
        decoration: HomeCardTheme.cardDecoration(
          scheme: scheme,
          brightness: brightness,
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
              _buildArisHeaderRow(
                scheme: scheme,
                isDark: isDark,
                arisIconColor: arisIconColor,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 58,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: isSending
                      ? ArisThinkingIndicator(
                          compact: true,
                          dotColor: HomeCardTheme.thinkingDot(
                            scheme,
                            brightness,
                          ),
                          textStyle: TextStyle(
                            fontSize: 14.5,
                            height: 1.32,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                    .withValues(alpha: 0.92)
                                : AppColors.textSecondaryLight,
                          ),
                        )
                      : Text(
                          activeMessage,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Input de Aris anclado al pie de Inicio — barra compacta sin tarjeta (v0.48.49).
class HomeArisFixedInputBar extends StatefulWidget {
  /// Altura de referencia: padding vertical + fila de campo.
  static const double dockHeight = 6 + 40 + 6;

  const HomeArisFixedInputBar({
    super.key,
    required this.isSending,
    this.hintText = 'Escribe a Aris…',
    this.onSubmit,
    this.onMicPressed,
  });

  final bool isSending;
  final String hintText;
  final Future<void> Function(String text)? onSubmit;
  final VoidCallback? onMicPressed;

  @override
  State<HomeArisFixedInputBar> createState() => _HomeArisFixedInputBarState();
}

class _HomeArisFixedInputBarState extends State<HomeArisFixedInputBar> {
  final _controller = TextEditingController();

  static const double _padV = 6;
  static const double _inputHeight = 40;
  static const double _inputRadius = 22;
  static const double _inputPadH = 14;
  static const double _micSize = 34;
  static const double _micIconSize = 20;

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

  Future<void> _handleSubmit(String raw) async {
    final t = raw.trim();
    if (t.isEmpty || widget.isSending) return;
    _controller.clear();
    await widget.onSubmit?.call(t);
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
              : () => _handleSubmit(_controller.text),
          style: FilledButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
            minimumSize: const Size(_micSize, _micSize),
            maximumSize: const Size(_micSize, _micSize),
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final arisAccent =
        isDark ? _kArisTitleDark : AppColors.secondaryViolet;

    final inputBg = isDark
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.62)
        : scheme.surfaceContainerHigh.withValues(alpha: 0.72);

    final borderColor = isDark
        ? HomeCardTheme.panelBorder(scheme, Brightness.dark)
            .withValues(alpha: 0.55)
        : scheme.outline.withValues(alpha: 0.14);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.homePageMarginH,
        _padV,
        AppSpacing.homePageMarginH,
        _padV,
      ),
      child: SizedBox(
        height: _inputHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(_inputRadius),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: !widget.isSending,
                  textInputAction: TextInputAction.send,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.2,
                    color: scheme.onSurface,
                  ),
                  onSubmitted: _handleSubmit,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      fontSize: 14,
                      height: 1.2,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.68),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: _inputPadH,
                      vertical: 10,
                    ),
                    isDense: true,
                    isCollapsed: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildTrailingAction(scheme, isDark, arisAccent),
          ],
        ),
      ),
    );
  }
}
