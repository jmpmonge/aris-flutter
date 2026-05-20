import 'package:flutter/material.dart';

import '../../../../core/repositories/repositories.dart';
import '../../../../core/services/chat_service.dart';
import '../../../../shared/widgets/chat_input_bar.dart';
import '../../../../shared/widgets/recent_conversation_card.dart';
import '../../../../theme/app_spacing.dart';

/// Panel inside con conversación completa — ocupa el alto disponible (v0.48.44).
class HomeArisChatInsideSheet extends StatefulWidget {
  const HomeArisChatInsideSheet({
    super.key,
    required this.onSend,
    required this.onMicTap,
  });

  final Future<void> Function(String text) onSend;
  final VoidCallback onMicTap;

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function(String text) onSend,
    required VoidCallback onMicTap,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HomeArisChatInsideSheet(
        onSend: onSend,
        onMicTap: onMicTap,
      ),
    );
  }

  @override
  State<HomeArisChatInsideSheet> createState() =>
      _HomeArisChatInsideSheetState();
}

class _HomeArisChatInsideSheetState extends State<HomeArisChatInsideSheet> {
  final _inputController = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    ChatService.revision.addListener(_onRevision);
    Repositories.history.revision.addListener(_onRevision);
  }

  @override
  void dispose() {
    ChatService.revision.removeListener(_onRevision);
    Repositories.history.revision.removeListener(_onRevision);
    _inputController.dispose();
    super.dispose();
  }

  void _onRevision() {
    if (mounted) setState(() {});
  }

  Future<void> _handleSend(String text) async {
    final t = text.trim();
    if (t.isEmpty || _sending) return;
    _inputController.clear();
    setState(() => _sending = true);
    await widget.onSend(t);
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mq = MediaQuery.of(context);
    final topInset = mq.padding.top;
    final bottomInset = mq.viewInsets.bottom;
    final sheetHeight = mq.size.height - topInset - 12;

    final messages = Repositories.history.conversationForHome();

    return Padding(
      padding: EdgeInsets.only(top: topInset + 12, bottom: bottomInset),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: scheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.homeCardRadius),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: sheetHeight,
            width: mq.size.width,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 4, 4),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Text(
                        'Conversación con Aris',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Cerrar',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RecentConversationCard(
                    messages: messages,
                    onFollowUpMessage: _handleSend,
                    onOpenFullChat: null,
                    expandBody: true,
                    embeddedInPanel: true,
                  ),
                ),
                ChatInputBar(
                  controller: _inputController,
                  hintText: 'Escribe a Aris…',
                  isSending: _sending,
                  onSend: _handleSend,
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
