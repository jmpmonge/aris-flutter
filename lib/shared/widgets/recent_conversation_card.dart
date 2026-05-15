import 'package:flutter/material.dart';

import '../../core/models/chat_message_model.dart';
import '../../core/models/intent_model.dart';
import '../../theme/app_spacing.dart';

/// Bloque **RECIENTE** con burbujas tipo chat (mock).
///
/// La lista de mensajes tiene [AppSpacing.recentConversationBodyMaxHeight] como
/// altura máxima y hace scroll interno para no desbordar la pantalla de Inicio.
class RecentConversationCard extends StatefulWidget {
  const RecentConversationCard({super.key, required this.messages});

  final List<ChatMessageModel> messages;

  @override
  State<RecentConversationCard> createState() => _RecentConversationCardState();
}

class _RecentConversationCardState extends State<RecentConversationCard> {
  final ScrollController _listController = ScrollController();

  @override
  void didUpdateWidget(covariant RecentConversationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length != oldWidget.messages.length) {
      _scrollMessagesToEnd();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollMessagesToEnd());
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  void _scrollMessagesToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_listController.hasClients) return;
      final pos = _listController.position;
      _listController.jumpTo(pos.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.07),
              blurRadius: AppSpacing.shadowBlurChat,
              offset: AppSpacing.shadowOffsetChat,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RECIENTE',
                style: text.titleSmall?.copyWith(
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: AppSpacing.recentConversationBodyMaxHeight,
                child: ListView.separated(
                  controller: _listController,
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  itemCount: widget.messages.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final m = widget.messages[i];
                    return _Bubble(
                      alignLeft: m.isAris,
                      label: m.isAris ? 'ARIS' : 'TÚ',
                      text: m.text,
                      intent: m.detectedIntent,
                      scheme: scheme,
                      textTheme: text,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.alignLeft,
    required this.label,
    required this.text,
    this.intent,
    required this.scheme,
    required this.textTheme,
  });

  final bool alignLeft;
  final String label;
  final String text;
  final IntentModel? intent;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      constraints: const BoxConstraints(
        maxWidth: AppSpacing.chatBubbleMaxWidth,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: alignLeft ? scheme.surfaceContainerHigh : scheme.primary,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppSpacing.radiusMd),
          topRight: const Radius.circular(AppSpacing.radiusMd),
          bottomLeft: Radius.circular(
            alignLeft ? AppSpacing.radiusTail : AppSpacing.radiusMd,
          ),
          bottomRight: Radius.circular(
            alignLeft ? AppSpacing.radiusMd : AppSpacing.radiusTail,
          ),
        ),
        border: alignLeft
            ? Border.all(color: scheme.outline.withValues(alpha: 0.2))
            : null,
        boxShadow: alignLeft
            ? null
            : [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.22),
                  blurRadius: AppSpacing.shadowBlurLift,
                  offset: AppSpacing.shadowOffsetLift,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.8,
                    color: alignLeft
                        ? scheme.secondary
                        : scheme.onPrimary.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (alignLeft &&
                  intent != null &&
                  intent!.type != IntentType.unknown) ...[
                const SizedBox(width: AppSpacing.xs),
                _IntentChip(
                  label: intent!.chipLabel,
                  scheme: scheme,
                  textTheme: textTheme,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            text,
            style: textTheme.bodyMedium?.copyWith(
              color: alignLeft ? scheme.onSurface : scheme.onPrimary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );

    return Align(
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: bubble,
    );
  }
}

class _IntentChip extends StatelessWidget {
  const _IntentChip({
    required this.label,
    required this.scheme,
    required this.textTheme,
  });

  final String label;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: 2,
        ),
        child: Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            letterSpacing: 0.6,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: scheme.onSecondaryContainer.withValues(alpha: 0.92),
          ),
        ),
      ),
    );
  }
}
