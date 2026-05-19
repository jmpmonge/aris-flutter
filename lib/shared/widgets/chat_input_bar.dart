import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Barra fija “Escribe a Aris…” — altura compacta; solo UI.
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    this.hintText = 'Mensaje…',
    this.isSending = false,
    this.onSend,
    this.onMicTap,
  });

  final TextEditingController controller;
  final String hintText;

  /// Mientras llega respuesta HTTP del asistente.
  final bool isSending;

  final void Function(String text)? onSend;
  final VoidCallback? onMicTap;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  bool get _hasText => widget.controller.text.trim().isNotEmpty;

  static const double _micSize = AppSpacing.homeChatMicButtonSize;
  static const double _micIconSize = 24;
  static const double _barHeight = AppSpacing.homeChatInputHeight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Material(
      color: bg,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.homePageMarginH,
          AppSpacing.xs,
          AppSpacing.homePageMarginH,
          MediaQuery.paddingOf(context).bottom > 0
              ? AppSpacing.xxs
              : AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: bg,
          border: Border(
            top: BorderSide(color: scheme.outline.withValues(alpha: 0.10)),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: _barHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppSpacing.homeCardRadius),
                      border: Border.all(
                        color: scheme.outline.withValues(alpha: 0.14),
                      ),
                    ),
                    child: TextField(
                      controller: widget.controller,
                      textInputAction: TextInputAction.send,
                      enabled: !widget.isSending,
                      maxLines: 1,
                      minLines: 1,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14.5,
                            height: 1.25,
                          ),
                      onSubmitted: (v) {
                        if (widget.isSending || v.trim().isEmpty) return;
                        widget.onSend?.call(v);
                      },
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14.5,
                              color: scheme.onSurfaceVariant.withValues(alpha: 0.72),
                            ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (_hasText)
                  SizedBox(
                    width: _micSize,
                    height: _micSize,
                    child: FilledButton(
                      onPressed: widget.isSending
                          ? null
                          : () {
                              final t = widget.controller.text.trim();
                              if (t.isEmpty) return;
                              widget.onSend?.call(t);
                            },
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(_micSize, _micSize),
                        maximumSize: const Size(_micSize, _micSize),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: widget.isSending
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              Icons.send_rounded,
                              size: AppSpacing.iconFab,
                              color: scheme.onPrimary,
                            ),
                    ),
                  )
                else
                  _MicButton(
                    isSending: widget.isSending,
                    isDark: isDark,
                    micSize: _micSize,
                    micIconSize: _micIconSize,
                    onMicTap: widget.onMicTap,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Micrófono: claro sin cambios; oscuro fondo neutro v0.48.18 (#303746, borde lavanda suave).
class _MicButton extends StatelessWidget {
  const _MicButton({
    required this.isSending,
    required this.isDark,
    required this.micSize,
    required this.micIconSize,
    required this.onMicTap,
  });

  final bool isSending;
  final bool isDark;
  final double micSize;
  final double micIconSize;
  final VoidCallback? onMicTap;

  static const Color _kDarkMicBg = Color(0xFF303746);
  static const Color _kDarkMicIcon = Color(0xFFE8ECF4);
  static const Color _kDarkMicBorder = Color(0xFF4A456A);
  static const Color _kDarkPressedOverlay = Color(0xFF343B4A);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    void showDemoSnack() {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Micrófono · solo demo')),
      );
    }

    if (!isDark) {
      return Material(
        color: scheme.secondaryContainer.withValues(alpha: 0.65),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isSending
              ? null
              : (onMicTap ?? showDemoSnack),
          child: SizedBox(
            width: micSize,
            height: micSize,
            child: Icon(
              Icons.mic_none_rounded,
              size: micIconSize,
              color: scheme.onSecondaryContainer,
            ),
          ),
        ),
      );
    }

    return Container(
      width: micSize,
      height: micSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _kDarkMicBg,
        border: Border.all(
          color: _kDarkMicBorder.withValues(alpha: 0.32),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isSending
              ? null
              : (onMicTap ?? showDemoSnack),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return _kDarkPressedOverlay.withValues(alpha: 0.85);
            }
            if (states.contains(WidgetState.hovered)) {
              return Colors.white.withValues(alpha: 0.07);
            }
            return null;
          }),
          child: Center(
            child: Icon(
              Icons.mic_none_rounded,
              size: micIconSize,
              color: _kDarkMicIcon,
            ),
          ),
        ),
      ),
    );
  }
}
