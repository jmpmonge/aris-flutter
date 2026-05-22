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
import 'widgets/home_scroll_layout.dart';
import 'widgets/home_visible_counts.dart';
import '../../../shared/widgets/home_aris_reply_card.dart';
import '../../../shared/widgets/today_summary_card.dart';
import '../../../theme/app_spacing.dart';

/// Inicio — Aris en scroll, HOY crece si alarga el viewport (v0.48.54).
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onOpenCalendar,
    this.onOpenTasks,
  });

  final VoidCallback? onOpenCalendar;
  final VoidCallback? onOpenTasks;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  final _todaySummaryKey = GlobalKey();
  final _arisCardKey = GlobalKey();

  int _homeArisInstructionCount = 0;
  bool _arisSending = false;
  int _layoutTightenSteps = 0;
  bool _arisGuardScheduled = false;
  bool _viewportSyncScheduled = false;
  double? _lastListViewportHeight;
  double? _viewportSyncScheduledHeight;

  static const double _viewportGrowResetThreshold = 10;
  static const double _arisRelaxMarginBelow = 40;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureScrollAtTop();
      _guardArisVisibleInViewport();
    });
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

  void _scheduleArisVisibilityGuard() {
    if (_arisGuardScheduled) return;
    _arisGuardScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _arisGuardScheduled = false;
      _guardArisVisibleInViewport();
    });
  }

  void _scheduleViewportHeightSync(double listViewportHeight) {
    _viewportSyncScheduledHeight = listViewportHeight;
    if (_viewportSyncScheduled) return;
    _viewportSyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewportSyncScheduled = false;
      final height = _viewportSyncScheduledHeight;
      if (!mounted || height == null) return;
      _onListViewportHeightChanged(height);
    });
  }

  /// Al alargar la pantalla, libera el recorte de HOY para volver a crecer.
  void _onListViewportHeightChanged(double height) {
    final previous = _lastListViewportHeight;
    _lastListViewportHeight = height;

    if (previous == null) return;

    if (height > previous + _viewportGrowResetThreshold &&
        _layoutTightenSteps > 0) {
      setState(() => _layoutTightenSteps = 0);
      _scheduleArisVisibilityGuard();
      return;
    }

    if (height < previous - _viewportGrowResetThreshold) {
      _scheduleArisVisibilityGuard();
    }
  }

  /// Aprieta o afloja HOY según si Aris cabe en el viewport del scroll.
  void _guardArisVisibleInViewport() {
    if (!mounted) return;

    final arisContext = _arisCardKey.currentContext;
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

    final arisBottom = arisBox
        .localToGlobal(
          Offset(0, arisBox.size.height),
          ancestor: scrollableBox,
        )
        .dy;
    const epsilon = 2;

    final viewportH = scrollableBox.size.height;

    if (arisBottom > viewportH - epsilon) {
      if (_layoutTightenSteps < 9) {
        setState(() => _layoutTightenSteps++);
        _scheduleArisVisibilityGuard();
      }
      return;
    }

    if (_layoutTightenSteps > 0 &&
        arisBottom < viewportH - _arisRelaxMarginBelow) {
      setState(() => _layoutTightenSteps--);
      _scheduleArisVisibilityGuard();
    }
  }

  void _onHomeDataRevision() {
    if (!mounted) return;
    setState(() {
      _layoutTightenSteps = 0;
    });
    _scheduleArisVisibilityGuard();
  }

  void _onLocalActions() {
    if (!mounted) return;
    setState(() {
      _layoutTightenSteps = 0;
    });
    _scheduleArisVisibilityGuard();
  }

  void _onConversationRevision() {
    if (!mounted) return;
    setState(() {
      _layoutTightenSteps = 0;
    });
    _scheduleArisVisibilityGuard();
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
                _scheduleViewportHeightSync(constraints.maxHeight);

                final baseCounts = HomeVisibleCounts.forListViewport(
                  listViewportHeight: constraints.maxHeight,
                  context: context,
                  availableEvents: homeEvents.length,
                  availableTasks: homeTasks.length,
                  availableMails: TodaySummaryCard.demoMailCatalogLength,
                );
                final visibleCounts =
                    baseCounts.tightened(_layoutTightenSteps);

                _scheduleArisVisibilityGuard();

                return ListView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.only(
                    bottom: HomeScrollLayout.scrollContentBottomPadding(
                      context,
                    ),
                  ),
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
                    ),
                    SizedBox(
                      height: HomeScrollLayout.sectionGapBeforeAris(context),
                    ),
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
