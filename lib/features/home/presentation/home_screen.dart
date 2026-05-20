import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/models/chat_message_model.dart';
import '../../../core/repositories/repositories.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/services/local_action_service.dart';
import 'widgets/home_aris_chat_inside_sheet.dart';
import 'widgets/home_aris_conversation_utils.dart';
import 'widgets/home_ephemeral_greeting_header.dart';
import 'widgets/home_fixed_date_header.dart';
import 'widgets/home_visible_counts.dart';
import '../../../shared/widgets/home_aris_reply_card.dart';
import '../../../shared/widgets/today_summary_card.dart';
import '../../../theme/app_spacing.dart';

/// Inicio — contenido scrollable + input Aris fijo (v0.48.47).
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onOpenCalendar,
    this.onOpenTasks,
    this.onOpenMail,
  });

  final VoidCallback? onOpenCalendar;
  final VoidCallback? onOpenTasks;
  final VoidCallback? onOpenMail;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  final _todaySummaryKey = GlobalKey();
  final _arisCardKey = GlobalKey();

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
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureScrollAtTop());
  }

  void scrollToTop() => _ensureScrollAtTop();

  void _ensureScrollAtTop() {
    if (!mounted || !_scrollController.hasClients) return;
    if (_scrollController.offset != 0) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    Repositories.calendar.readRevision.removeListener(_onHomeDataRevision);
    Repositories.note.readRevision.removeListener(_onHomeDataRevision);
    Repositories.task.readRevision.removeListener(_onHomeDataRevision);
    ChatService.revision.removeListener(_onConversationRevision);
    Repositories.history.revision.removeListener(_onConversationRevision);
    LocalActionService.revision.removeListener(_onLocalActions);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() => _preventArisScrollPastTop();

  /// Evita pasar de scroll: no deja hueco vacío por encima de Aris ni la corta.
  void _preventArisScrollPastTop() {
    if (!_scrollController.hasClients) return;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      final arisContext = _arisCardKey.currentContext;
      final todayContext = _todaySummaryKey.currentContext;
      if (arisContext == null) return;

      final scrollable = Scrollable.maybeOf(arisContext);
      if (scrollable == null) return;

      final scrollableBox =
          scrollable.context.findRenderObject() as RenderBox?;
      final arisBox = arisContext.findRenderObject() as RenderBox?;
      if (scrollableBox == null ||
          arisBox == null ||
          !scrollableBox.hasSize ||
          !arisBox.hasSize) {
        return;
      }

      // Solo cuando HOY ya no ocupa el viewport (Aris es el bloque superior visible).
      if (todayContext != null) {
        final todayBox = todayContext.findRenderObject() as RenderBox?;
        if (todayBox != null && todayBox.hasSize) {
          final todayBottom = todayBox
              .localToGlobal(
                Offset(0, todayBox.size.height),
                ancestor: scrollableBox,
              )
              .dy;
          if (todayBottom > 0) return;
        }
      }

      final arisTop =
          arisBox.localToGlobal(Offset.zero, ancestor: scrollableBox).dy;
      const epsilon = 0.5;

      // Solo frena si la tarjeta se pasa por arriba (no empujar más hacia arriba).
      if (arisTop < -epsilon) {
        final target = (_scrollController.offset + arisTop).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );
        if ((target - _scrollController.offset).abs() > epsilon) {
          _scrollController.jumpTo(target);
        }
      }
    });
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
      _arisSending || _homeConversation.any((m) => m.awaitingBackend);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HomeFixedDateHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final visibleCounts = HomeVisibleCounts.forListViewport(
                  listViewportHeight: constraints.maxHeight,
                  availableEvents: homeEvents.length,
                  availableTasks: homeTasks.length,
                  availableMails: TodaySummaryCard.demoMailCatalogLength,
                );

                return ListView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppSpacing.homeFixedDateToEphemeralGap,
                        bottom: AppSpacing.homeGreetingToHoyGap,
                      ),
                      child: const HomeEphemeralGreetingHeader(),
                    ),
                    TodaySummaryCard(
                      key: _todaySummaryKey,
                      events: homeEvents,
                      tasks: homeTasks,
                      maxAgendaItems: visibleCounts.agendaItems,
                      maxTaskItems: visibleCounts.taskItems,
                      maxMailItems: visibleCounts.mailItems,
                      onOpenCalendar: widget.onOpenCalendar,
                      onOpenTasks: widget.onOpenTasks,
                      onOpenMail: widget.onOpenMail,
                    ),
                    const SizedBox(height: AppSpacing.homeSectionGapMax),
                    HomeArisReplyCard(
                      key: _arisCardKey,
                      activeMessage: arisDisplayMessage,
                      isSending: _arisIsThinking,
                      onOpenFullConversation: () =>
                          HomeArisChatInsideSheet.show(
                        context,
                        onSend: _sendArisMessage,
                        onMicTap: _onMicPressed,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          HomeArisFixedInputBar(
            isSending: _arisIsThinking,
            onSubmit: _sendArisMessage,
            onMicPressed: _onMicPressed,
          ),
        ],
      ),
    );
  }
}
