import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/models/chat_message_model.dart';
import '../../core/models/intent_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Overlay cabecera CHAT CON ARIS: claro lavanda pálido; oscuro hover lavanda (v0.48.15+).
/// Pressed en oscuro: neutro #303746 (v0.48.18).
WidgetStateProperty<Color?> _chatHeaderOverlayColor(bool isDark) {
  const light = Color(0xFFF0EEFF);
  const lightHover = Color(0xFFEDE9FF);
  const darkInk = Color(0xFF2B2547);
  const darkPressed = Color(0xFF303746);
  return WidgetStateProperty.resolveWith((states) {
    if (isDark) {
      if (states.contains(WidgetState.pressed)) {
        return darkPressed.withValues(alpha: 0.96);
      }
      if (states.contains(WidgetState.hovered) ||
          states.contains(WidgetState.focused)) {
        return darkInk.withValues(alpha: 0.85);
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

/// Firma para enviar mensajes de seguimiento (`POST /message`) desde la UI,
/// p. ej. `"sí"` / `"no"` tras `ui_hint == confirm_rescue`.
typedef ChatFollowUpSender = Future<void> Function(String text);

/// Fondos burbuja chat Home en oscuro (v0.48.16+; Aris aclarado v0.48.18 #242A38).
const Color _chatBubbleArisBgDark = Color(0xFF242A38);
const Color _chatBubbleUserBgDark = Color(0xFF2A3346);
const Color _chatBubbleBorderDark = Color(0xFF2A2F3A);
const Color _chatDarkPrimaryText = Color(0xFFE8ECF4);
const Color _chatDarkSecondaryText = Color(0xFFC3CAD6);
const Color _chatDarkAccentLavender = Color(0xFFB8AEFF);

/// Bloque **CHAT CON ARIS** con burbujas tipo chat (histórico reciente).
///
/// La lista de mensajes tiene [AppSpacing.recentConversationBodyMaxHeight] como
/// altura máxima y hace scroll interno para no desbordar la pantalla de Inicio.
class RecentConversationCard extends StatefulWidget {
  const RecentConversationCard({
    super.key,
    required this.messages,
    this.onFollowUpMessage,
    this.onOpenFullChat,
  });

  final List<ChatMessageModel> messages;

  /// Opcional: si es null, no se muestran acciones para `confirm_rescue`.
  final ChatFollowUpSender? onFollowUpMessage;

  /// Abre el chat a pantalla completa (p. ej. [AssistantScreen]) desde el título.
  final VoidCallback? onOpenFullChat;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.homePageMarginH),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.homeCardRadius),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: isDark ? 0.05 : 0.09),
              blurRadius: AppSpacing.shadowBlurHomeCard,
              offset: AppSpacing.shadowOffsetHomeCard,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.homeCardPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ChatWithArisHeader(
                scheme: scheme,
                isDark: isDark,
                onOpenFullChat: widget.onOpenFullChat,
              ),
              const SizedBox(height: AppSpacing.sm),
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
                      const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, i) {
                    final m = widget.messages[i];
                    return _Bubble(
                      alignLeft: m.isAris,
                      label: m.isAris ? 'ARIS' : 'TÚ',
                      text: m.text,
                      intent: m.detectedIntent,
                      backendUiHint: m.backendUiHint,
                      awaitingBackend: m.awaitingBackend,
                      scheme: scheme,
                      textTheme: text,
                      onFollowUpMessage: widget.onFollowUpMessage,
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

/// Cabecera (v0.48.14): fila completa pulsable + overlay lavanda; tap abre chat si hay callback.
///
/// Patrón compartido con HOY / SUGERENCIA — [AppSpacing.homeCardHeader*] (v0.48.24).
class _ChatWithArisHeader extends StatelessWidget {
  const _ChatWithArisHeader({
    required this.scheme,
    required this.isDark,
    this.onOpenFullChat,
  });

  final ColorScheme scheme;
  final bool isDark;
  final VoidCallback? onOpenFullChat;

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.7,
      height: 1.0,
      color: isDark
          ? _chatDarkPrimaryText
          : AppColors.primaryDeep,
    );

    const chatHeaderAccentDark = _chatDarkAccentLavender;

    final iconColor =
        isDark ? chatHeaderAccentDark : AppColors.secondaryViolet;

    final row = ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: AppSpacing.homeCardHeaderMinHeight,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: AppSpacing.homeCardHeaderIconSize,
            color: iconColor,
          ),
          SizedBox(width: AppSpacing.homeCardHeaderIconTitleGap),
          Expanded(
            child: Text(
              'CHAT CON ARIS',
              style: titleStyle,
            ),
          ),
          SizedBox(
            width: AppSpacing.homeCardHeaderChevronBox,
            height: AppSpacing.homeCardHeaderChevronBox,
            child: Center(
              child: Icon(
                Icons.chevron_right_rounded,
                size: AppSpacing.homeCardHeaderChevronSize,
                color: isDark
                    ? chatHeaderAccentDark.withValues(alpha: 0.55)
                    : scheme.onSurfaceVariant.withValues(alpha: 0.72),
              ),
            ),
          ),
        ],
      ),
    );

    if (onOpenFullChat == null) {
      return row;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpenFullChat,
        borderRadius: BorderRadius.circular(
          AppSpacing.homeCardHeaderInkBorderRadius,
        ),
        overlayColor: _chatHeaderOverlayColor(isDark),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.homeCardHeaderInkPaddingH,
            vertical: AppSpacing.homeCardHeaderInkPaddingV,
          ),
          child: row,
        ),
      ),
    );
  }
}

bool _messageMayNeedConfirmationFootnote(String text, String? backendUiHint) {
  if (backendUiHint != null && backendUiHint.isNotEmpty) return false;
  final t = text.toLowerCase();
  return t.contains('provisional') || t.contains('provisoria');
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.alignLeft,
    required this.label,
    required this.text,
    this.intent,
    this.backendUiHint,
    this.awaitingBackend = false,
    required this.scheme,
    required this.textTheme,
    this.onFollowUpMessage,
  });

  final bool alignLeft;
  final String label;
  final String text;
  final IntentModel? intent;
  final String? backendUiHint;
  final bool awaitingBackend;
  final ColorScheme scheme;
  final TextTheme textTheme;
  final ChatFollowUpSender? onFollowUpMessage;

  bool get _showIntentChip =>
      alignLeft &&
      !awaitingBackend &&
      intent != null &&
      intent!.type != IntentType.unknown;

  bool get _showConfirmRescue =>
      alignLeft &&
      !awaitingBackend &&
      backendUiHint == 'confirm_rescue' &&
      onFollowUpMessage != null;

  bool get _showProvisionalFootnote =>
      alignLeft &&
      !awaitingBackend &&
      _messageMayNeedConfirmationFootnote(text, backendUiHint);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleBackground = alignLeft
        ? (isDark ? _chatBubbleArisBgDark : AppColors.softBlue)
        : (isDark ? _chatBubbleUserBgDark : AppColors.softGreen);
    final labelColor = isDark ? _chatDarkPrimaryText : AppColors.primaryDeep;
    final bodyTextColor = isDark ? _chatDarkPrimaryText : scheme.onSurface;

    final bubble = Container(
      constraints: const BoxConstraints(
        maxWidth: AppSpacing.chatBubbleMaxWidth,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bubbleBackground,
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
        border: Border.all(
          color: isDark
              ? _chatBubbleBorderDark.withValues(alpha: 0.42)
              : scheme.outline.withValues(alpha: 0.16),
        ),
        boxShadow: alignLeft
            ? null
            : [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.28)
                      : AppColors.primaryDeep.withValues(alpha: 0.07),
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
                    color: labelColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_showIntentChip) ...[
                const SizedBox(width: AppSpacing.xs),
                _IntentChip(
                  label: intent!.chipLabel,
                  scheme: scheme,
                  textTheme: textTheme,
                  isDark: isDark,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          if (awaitingBackend && alignLeft)
            Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: isDark
                        ? _chatDarkAccentLavender.withValues(alpha: 0.88)
                        : scheme.secondary.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    text,
                    style: textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? _chatDarkSecondaryText
                          : scheme.onSurfaceVariant,
                      height: 1.35,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            )
          else ...[
            Text(
              text,
              style: textTheme.bodyMedium?.copyWith(
                color: bodyTextColor,
                height: 1.35,
              ),
            ),
            if (_showProvisionalFootnote) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Puede requerir confirmación.',
                style: textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.2,
                  color: isDark
                      ? _chatDarkSecondaryText.withValues(alpha: 0.92)
                      : scheme.onSurfaceVariant.withValues(alpha: 0.88),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (_showConfirmRescue) ...[
              const SizedBox(height: AppSpacing.sm),
              _ConfirmRescuePanel(sender: onFollowUpMessage!),
            ] else if (alignLeft &&
                backendUiHint != null &&
                backendUiHint!.isNotEmpty &&
                backendUiHint != 'confirm_rescue') ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Hint de servidor · $backendUiHint',
                style: textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.35,
                  color: isDark
                      ? _chatDarkSecondaryText.withValues(alpha: 0.94)
                      : scheme.onSurfaceVariant.withValues(alpha: 0.92),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ],
      ),
    );

    return Align(
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: bubble,
    );
  }
}

/// Acciones [Guardar] → `"sí"`, [Cancelar] → `"no"` (v0.44.1).
class _ConfirmRescuePanel extends StatefulWidget {
  const _ConfirmRescuePanel({required this.sender});

  final ChatFollowUpSender sender;

  @override
  State<_ConfirmRescuePanel> createState() => _ConfirmRescuePanelState();
}

class _ConfirmRescuePanelState extends State<_ConfirmRescuePanel> {
  bool _busy = false;

  Future<void> _submit(String choice) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.sender(choice);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Necesito confirmación',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'El backend ha dejado una acción pendiente.',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                TextButton(
                  onPressed: _busy ? null : () => unawaited(_submit('sí')),
                  child: _busy
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: scheme.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Enviando…',
                              style: textTheme.labelLarge?.copyWith(
                                color: scheme.primary,
                              ),
                            ),
                          ],
                        )
                      : const Text('Guardar'),
                ),
                const SizedBox(width: AppSpacing.xs),
                TextButton(
                  onPressed: _busy ? null : () => unawaited(_submit('no')),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IntentChip extends StatelessWidget {
  const _IntentChip({
    required this.label,
    required this.scheme,
    required this.textTheme,
    required this.isDark,
  });

  final String label;
  final ColorScheme scheme;
  final TextTheme textTheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2B2547).withValues(alpha: 0.85)
            : scheme.secondaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: isDark
              ? _chatDarkAccentLavender.withValues(alpha: 0.32)
              : scheme.outline.withValues(alpha: 0.18),
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
            color: isDark
                ? _chatDarkAccentLavender
                : scheme.onSecondaryContainer.withValues(alpha: 0.92),
          ),
        ),
      ),
    );
  }
}
