import 'package:flutter/material.dart';

import '../../../core/services/calendar_service.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/services/note_service.dart';
import '../../../core/services/task_service.dart';
import '../../../core/services/user_service.dart';
import '../../assistant/presentation/assistant_screen.dart';
import '../../../shared/widgets/home_brand_header.dart';
import '../../../shared/widgets/home_greeting_card.dart';
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
  }

  @override
  void dispose() {
    ChatService.revision.removeListener(_onChatRevision);
    _scrollController.dispose();
    super.dispose();
  }

  void _onChatRevision() {
    if (!mounted) return;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _openAssistant(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const AssistantScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        key: const Key('tab_home'),
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: AppSpacing.homeSectionSpacing),
        children: [
          HomeBrandHeader(onAssistantTap: () => _openAssistant(context)),
          const SizedBox(height: AppSpacing.homeSectionSpacing),
          HomeGreetingCard(
            greeting: UserService.getGreetingForNow(),
            summary: UserService.getHomeSummaryLine(),
          ),
          const SizedBox(height: AppSpacing.homeSectionSpacing),
          SuggestionCard(message: UserService.getHomeSuggestionLine()),
          const SizedBox(height: AppSpacing.homeSectionSpacing),
          TodaySummaryCard(
            events: CalendarService.getHomeHighlightEvents(),
            tasks: TaskService.getHomeHighlightTasks(),
            notes: NoteService.getHomeHighlightNotes(),
          ),
          const SizedBox(height: AppSpacing.homeSectionSpacing),
          RecentConversationCard(messages: ChatService.getRecentConversation()),
        ],
      ),
    );
  }
}
