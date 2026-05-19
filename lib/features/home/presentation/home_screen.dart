import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/repositories/repositories.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/services/local_action_service.dart';
import '../../assistant/presentation/assistant_screen.dart';
import 'widgets/home_ephemeral_greeting_header.dart';
import '../../../shared/widgets/latest_aris_action_section.dart';
import '../../../shared/widgets/recent_conversation_card.dart';
import '../../../shared/widgets/today_summary_card.dart';
import '../../../theme/app_spacing.dart';

/// Colapso saludo temporal: altura ~360 ms + fade ~280 ms (v0.48.41).
Widget _greetingCollapseTransition(
  Widget child,
  Animation<double> animation,
) {
  const fadeMs = 280;
  const collapseMs = 360;
  final fadeEnd = fadeMs / collapseMs;

  final sizeAnimation = CurvedAnimation(
    parent: animation,
    curve: Curves.easeInOutCubic,
  );
  final fadeAnimation = CurvedAnimation(
    parent: animation,
    curve: Interval(0.0, fadeEnd, curve: Curves.easeOutCubic),
  );

  return ClipRect(
    child: SizeTransition(
      sizeFactor: sizeAnimation,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    ),
  );
}

/// Inicio — estructura vertical según prototipo funcional + estética premium Aris.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onOpenCalendar, this.onOpenTasks});

  /// Desde shell: ir a pestaña Calendario (índice fijo de app).
  final VoidCallback? onOpenCalendar;

  /// Desde shell: ir a pestaña Tareas (índice fijo de app).
  final VoidCallback? onOpenTasks;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();

  /// Saludo temporal visible al entrar (v0.48.41).
  bool _showGreetingHeader = true;

  Timer? _greetingAutoHideTimer;

  static const Duration _greetingCollapseDuration =
      Duration(milliseconds: 360);

  @override
  void initState() {
    super.initState();
    ChatService.revision.addListener(_onChatRevision);
    LocalActionService.revision.addListener(_onLocalActions);
    Repositories.history.revision.addListener(_onHistoryRevision);
    Repositories.task.readRevision.addListener(_onHomeDataRevision);
    Repositories.note.readRevision.addListener(_onHomeDataRevision);
    Repositories.calendar.readRevision.addListener(_onHomeDataRevision);
    _scrollController.addListener(_onHomeScroll);
    _startGreetingAutoHideTimer();
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
    _greetingAutoHideTimer?.cancel();
    _scrollController.removeListener(_onHomeScroll);
    Repositories.calendar.readRevision.removeListener(_onHomeDataRevision);
    Repositories.note.readRevision.removeListener(_onHomeDataRevision);
    Repositories.task.readRevision.removeListener(_onHomeDataRevision);
    Repositories.history.revision.removeListener(_onHistoryRevision);
    ChatService.revision.removeListener(_onChatRevision);
    LocalActionService.revision.removeListener(_onLocalActions);
    _scrollController.dispose();
    super.dispose();
  }

  void _startGreetingAutoHideTimer() {
    _greetingAutoHideTimer?.cancel();
    _greetingAutoHideTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) _hideGreetingHeader();
    });
  }

  void _onHomeScroll() {
    if (!_scrollController.hasClients || !_showGreetingHeader) return;
    if (_scrollController.offset > 0) {
      _hideGreetingHeader();
    }
  }

  /// Oculta el saludo temporal (tap, scroll, timer o input futuro).
  void _hideGreetingHeader() {
    if (!_showGreetingHeader) return;
    _greetingAutoHideTimer?.cancel();
    setState(() => _showGreetingHeader = false);
  }

  /// Pendiente: conectar con [ChatInputBar] al recibir foco (v0.48.42+).
  void hideGreetingHeaderFromInput() => _hideGreetingHeader();

  void _onHistoryRevision() => _onChatRevision();

  /// Calendario / tareas / notas: refrescar sin mover el scroll (v0.48.31).
  void _onHomeDataRevision() {
    if (!mounted) return;
    setState(() {});
  }

  void _onLocalActions() {
    if (!mounted) return;
    setState(() {});
  }

  /// Refresca bloque chat; sin desplazar scroll (v0.48.38).
  void _onChatRevision() {
    if (!mounted) return;
    setState(() {});
  }

  /// Seguimiento `POST /message` para `ui_hint == confirm_rescue` (p. ej. «sí» / «no»).
  Future<void> _sendChatFollowUp(String text) async {
    await Repositories.assistant.sendMessage(text);
  }

  void _openAssistant(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const AssistantScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasLatestArisAction = LocalActionService.getMostRecentAction() != null;
    final homeEvents = Repositories.calendar.getHomeHighlightEvents();
    final homeTasks = Repositories.task.getHomeHighlightTasks();

    return SafeArea(
      top: true,
      bottom: false,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.only(
          bottom: AppSpacing.homeSectionGap + AppSpacing.sm,
        ),
        children: [
          AnimatedSwitcher(
            duration: _greetingCollapseDuration,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: _greetingCollapseTransition,
            child: _showGreetingHeader
                ? Padding(
                    key: const ValueKey<String>('home_greeting_visible'),
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.homeGreetingToHoyGap,
                    ),
                    child: HomeEphemeralGreetingHeader(
                      eventCount: homeEvents.length,
                      taskCount: homeTasks.length,
                      onTap: _hideGreetingHeader,
                    ),
                  )
                : SizedBox(
                    key: const ValueKey<String>('home_greeting_hidden'),
                    height: AppSpacing.homeGreetingCollapsedGap,
                  ),
          ),
          TodaySummaryCard(
            events: homeEvents,
            tasks: homeTasks,
            onOpenCalendar: widget.onOpenCalendar,
            onOpenTasks: widget.onOpenTasks,
          ),
          if (hasLatestArisAction) ...[
            const SizedBox(height: AppSpacing.homeSectionGap),
            const LatestArisActionSection(),
          ],
          const SizedBox(height: AppSpacing.homeSectionGap),
          RecentConversationCard(
            messages: Repositories.history.conversationForHome(),
            onFollowUpMessage: _sendChatFollowUp,
            onOpenFullChat: () => _openAssistant(context),
          ),
        ],
      ),
    );
  }
}
