import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Barra fija de mensaje: micrófono si vacío, enviar si hay texto (solo UI local).
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    this.hintText = 'Mensaje…',
    this.onSend,
    this.onMicTap,
  });

  final TextEditingController controller;
  final String hintText;
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          MediaQuery.paddingOf(context).bottom > 0
              ? AppSpacing.xs
              : AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: isDark ? 0.92 : 0.97),
          border: Border(
            top: BorderSide(color: scheme.outline.withValues(alpha: 0.18)),
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.05),
              blurRadius: AppSpacing.shadowBlurBar,
              offset: AppSpacing.shadowOffsetBar,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(
                      color: scheme.outline.withValues(alpha: 0.15),
                    ),
                  ),
                  child: TextField(
                    controller: widget.controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (v) {
                      if (v.trim().isEmpty) return;
                      widget.onSend?.call(v);
                    },
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (_hasText)
                FilledButton(
                  onPressed: () {
                    final t = widget.controller.text.trim();
                    if (t.isEmpty) return;
                    widget.onSend?.call(t);
                  },
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    minimumSize: const Size(
                      AppSpacing.minTouchTarget,
                      AppSpacing.minTouchTarget,
                    ),
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    size: AppSpacing.iconFab,
                  ),
                )
              else
                IconButton.filledTonal(
                  onPressed:
                      widget.onMicTap ??
                      () {
                        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                          const SnackBar(
                            content: Text('Micrófono · solo demo'),
                          ),
                        );
                      },
                  icon: const Icon(Icons.mic_none_rounded),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(
                      AppSpacing.minTouchTarget,
                      AppSpacing.minTouchTarget,
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
