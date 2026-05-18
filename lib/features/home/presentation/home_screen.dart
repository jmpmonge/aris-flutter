import 'package:flutter/material.dart';

import '../../../core/repositories/repositories.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/services/local_action_service.dart';
import '../../../core/services/user_service.dart';
import '../../assistant/presentation/assistant_screen.dart';
import 'widgets/aris_header.dart';
import 'widgets/greeting_card.dart';
import '../../../shared/widgets/latest_aris_action_section.dart';
import '../../../shared/widgets/recent_conversation_card.dart';
import '../../../shared/widgets/suggestion_card.dart';
import '../../../shared/widgets/today_summary_card.dart';
import '../../../theme/app_spacing.dart';

/// Inicio — estructura vertical según prototipo funcional + estética premium Aris.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ChatService.revision.addListener(_onChatRevision);
    LocalActionService.revision.addListener(_onLocalActions);
    Repositories.history.revision.addListener(_onHistoryRevision);
    Repositories.task.readRevision.addListener(_onChatRevision);
    Repositories.note.readRevision.addListener(_onChatRevision);
    Repositories.calendar.readRevision.addListener(_onChatRevision);
  }

  @override
  void dispose() {
    Repositories.calendar.readRevision.removeListener(_onChatRevision);
    Repositories.note.readRevision.removeListener(_onChatRevision);
    Repositories.task.readRevision.removeListener(_onChatRevision);
    Repositories.history.revision.removeListener(_onHistoryRevision);
    ChatService.revision.removeListener(_onChatRevision);
    LocalActionService.revision.removeListener(_onLocalActions);
    _scrollController.dispose();
    super.dispose();
  }

  void _onHistoryRevision() => _onChatRevision();
  void _onLocalActions() {
    if (!mounted) return;
    setState(() {});
  }

  void _onChatRevision() {
    if (!mounted) return;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
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
    return SafeArea(
      top: true,
      bottom: false,
      child: ListView(
        key: const Key('tab_home'),
        controller: _scrollController,
        padding: const EdgeInsets.only(
          bottom: AppSpacing.homeSectionSpacing + AppSpacing.sm,
        ),
        children: [
          ArisHeader(onAssistantTap: () => _openAssistant(context)),
          const SizedBox(height: 17),
          GreetingCard(
            greeting: UserService.getGreetingForNow(),
            secondaryLines: const [
              'Dos tareas importantes',
              'y un hueco útil a las 11:30.',
            ],
          ),
          const SizedBox(height: AppSpacing.homeSectionSpacing),
          SuggestionCard(message: UserService.getHomeSuggestionLine()),
          const SizedBox(height: AppSpacing.homeSectionSpacing),
          TodaySummaryCard(
            events: Repositories.calendar.getHomeHighlightEvents(),
            tasks: Repositories.task.getHomeHighlightTasks(),
            notes: Repositories.note.getHomeHighlightNotes(),
          ),
          const SizedBox(height: AppSpacing.homeSectionSpacing),
          const LatestArisActionSection(),
          const SizedBox(height: AppSpacing.homeSectionSpacing),
          RecentConversationCard(
            messages: Repositories.history.conversationForHome(),
            onFollowUpMessage: _sendChatFollowUp,
          ),
        ],
      ),
    );
  }
}
