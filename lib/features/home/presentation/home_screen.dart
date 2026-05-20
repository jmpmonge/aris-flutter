import 'package:flutter/material.dart';

import '../../../core/models/chat_message_model.dart';
import '../../../core/repositories/repositories.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/services/local_action_service.dart';
import 'widgets/home_aris_chat_inside_sheet.dart';
import 'widgets/home_aris_conversation_utils.dart';
import 'widgets/home_ephemeral_greeting_header.dart';
import 'widgets/home_fixed_date_header.dart';
import '../../../shared/widgets/home_aris_reply_card.dart';
import '../../../shared/widgets/today_summary_card.dart';
import '../../../theme/app_spacing.dart';

/// Inicio — estructura vertical según prototipo funcional + estética premium Aris.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onOpenCalendar,
    this.onOpenTasks,
    this.onOpenMail,
  });

  /// Desde shell: ir a pestaña Calendario (índice fijo de app).
  final VoidCallback? onOpenCalendar;

  /// Desde shell: ir a pestaña Tareas (índice fijo de app).
  final VoidCallback? onOpenTasks;

  /// Desde shell: abrir pantalla Mail.
  final VoidCallback? onOpenMail;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  int _homeArisInstructionCount = 0;
  bool _arisSending = false;

  @override
  void initState() {
    super.initState();
    LocalActionService.revision.addListener(_onLocalActions);
    Repositories.task.readRevision.addListener(_onHomeDataRevision);
    Repositories.note.readRevision.addListener(_onHomeDataRevision);
    Repositories.calendar.readRevision.addListener(_onHomeDataRevision);
    ChatService.revision.addListener(_onConversationRevision);
    Repositories.history.revision.addListener(_onConversationRevision);
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureScrollAtTop());
  }

  /// Restablece scroll al entrar en Inicio (v0.48.38).
  void scrollToTop() => _ensureScrollAtTop();

  void _ensureScrollAtTop() {
    if (!mounted || !_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    if (offset != 0) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    Repositories.calendar.readRevision.removeListener(_onHomeDataRevision);
    Repositories.note.readRevision.removeListener(_onHomeDataRevision);
    Repositories.task.readRevision.removeListener(_onHomeDataRevision);
    ChatService.revision.removeListener(_onConversationRevision);
    Repositories.history.revision.removeListener(_onConversationRevision);
    LocalActionService.revision.removeListener(_onLocalActions);
    _scrollController.dispose();
    super.dispose();
  }

  void _onHomeDataRevision() {
    if (!mounted) return;
    setState(() {});
  }

  void _onLocalActions() {
    if (!mounted) return;
    setState(() {});
  }

  void _onConversationRevision() {
    if (!mounted) return;
    setState(() {});
  }

  List<ChatMessageModel> get _homeConversation =>
      Repositories.history.conversationForHome();

  String get _lastArisMessage => homeLastArisMessageText(_homeConversation);

  bool get _arisIsThinking =>
      _arisSending ||
      _homeConversation.any((m) => m.awaitingBackend);

  Future<void> _sendArisMessage(String text) async {
    final t = text.trim();
    if (t.isEmpty) return;

    _homeArisInstructionCount++;
    setState(() => _arisSending = true);

    final result = await Repositories.assistant.sendMessage(t);

    if (!mounted) return;
    setState(() => _arisSending = false);

    final responseText = result.data?.text.trim() ?? '';
    final openForResponse = homeShouldOpenFullChatForResponse(
      text: responseText.isNotEmpty ? responseText : _lastArisMessage,
      uiHint: result.data?.uiHint,
    );

    if (_homeArisInstructionCount >= kHomeArisInstructionsBeforeInsideChat ||
        openForResponse) {
      await HomeArisChatInsideSheet.show(
        context,
        onSend: _sendArisMessage,
        onMicTap: _onMicPressed,
      );
    }
  }

  void _onMicPressed() {
    Repositories.assistant.sendVoicePendingNotice();
  }

  @override
  Widget build(BuildContext context) {
    final homeEvents = Repositories.calendar.getHomeHighlightEvents();
    final homeTasks = Repositories.task.getHomeHighlightTasks();
    final pendingTaskCount =
        homeTasks.where((t) => !t.completed).length;
    final arisDisplayMessage = homeArisCardDisplayMessage(
      messages: _homeConversation,
      eventCount: homeEvents.length,
      taskCount: pendingTaskCount,
    );

    return SafeArea(
      top: true,
      bottom: false,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.only(
          bottom: AppSpacing.homeSectionGap + AppSpacing.sm,
        ),
        children: [
          const HomeFixedDateHeader(),
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.homeFixedDateToEphemeralGap,
              bottom: AppSpacing.homeGreetingToHoyGap,
            ),
            child: const HomeEphemeralGreetingHeader(),
          ),
          TodaySummaryCard(
            events: homeEvents,
            tasks: homeTasks,
            onOpenCalendar: widget.onOpenCalendar,
            onOpenTasks: widget.onOpenTasks,
            onOpenMail: widget.onOpenMail,
          ),
          const SizedBox(height: AppSpacing.homeSectionGapMax),
          HomeArisReplyCard(
            activeMessage: arisDisplayMessage,
            isSending: _arisIsThinking,
            onOpenFullConversation: () => HomeArisChatInsideSheet.show(
              context,
              onSend: _sendArisMessage,
              onMicTap: _onMicPressed,
            ),
            onSubmit: _sendArisMessage,
            onMicPressed: _onMicPressed,
          ),
        ],
      ),
    );
  }
}
