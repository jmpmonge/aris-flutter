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

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
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
          color: scheme.surface.withValues(alpha: isDark ? 0.92 : 0.97),
          border: Border(
            top: BorderSide(color: scheme.outline.withValues(alpha: 0.16)),
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: isDark ? 0.05 : 0.08),
              blurRadius: AppSpacing.shadowBlurBar,
              offset: AppSpacing.shadowOffsetBar,
            ),
          ],
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
                  Material(
                    color: scheme.secondaryContainer.withValues(alpha: 0.65),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: widget.isSending
                          ? null
                          : (widget.onMicTap ??
                              () {
                                ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                                  const SnackBar(
                                    content: Text('Micrófono · solo demo'),
                                  ),
                                );
                              }),
                      child: SizedBox(
                        width: _micSize,
                        height: _micSize,
                        child: Icon(
                          Icons.mic_none_rounded,
                          size: _micIconSize,
                          color: scheme.onSecondaryContainer,
                        ),
                      ),
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
