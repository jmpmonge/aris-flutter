import 'package:flutter/material.dart';

import '../../../core/repositories/repositories.dart';
import '../../../core/services/local_action_service.dart';
import '../../assistant/presentation/assistant_screen.dart';
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

  @override
  void initState() {
    super.initState();
    LocalActionService.revision.addListener(_onLocalActions);
    Repositories.task.readRevision.addListener(_onHomeDataRevision);
    Repositories.note.readRevision.addListener(_onHomeDataRevision);
    Repositories.calendar.readRevision.addListener(_onHomeDataRevision);
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
    LocalActionService.revision.removeListener(_onLocalActions);
    _scrollController.dispose();
    super.dispose();
  }

  /// Calendario / tareas / notas: refrescar sin mover el scroll (v0.48.31).
  void _onHomeDataRevision() {
    if (!mounted) return;
    setState(() {});
  }

  void _onLocalActions() {
    if (!mounted) return;
    setState(() {});
  }

  void _openAssistant(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const AssistantScreen()),
    );
  }

  void _onMicPressed() {
    Repositories.assistant.sendVoicePendingNotice();
  }

  @override
  Widget build(BuildContext context) {
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
          const HomeFixedDateHeader(),
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.homeFixedDateToEphemeralGap,
              bottom: AppSpacing.homeGreetingToHoyGap,
            ),
            child: HomeEphemeralGreetingHeader(
              eventCount: homeEvents.length,
              taskCount: homeTasks.length,
            ),
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
            onOpenFullConversation: () => _openAssistant(context),
            onMicPressed: _onMicPressed,
          ),
        ],
      ),
    );
  }
}
