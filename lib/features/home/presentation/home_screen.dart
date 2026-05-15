import 'package:flutter/material.dart';

import '../../assistant/presentation/assistant_screen.dart';
import '../data/home_mock_content.dart';
import '../../../shared/widgets/home_brand_header.dart';
import '../../../shared/widgets/home_greeting_card.dart';
import '../../../shared/widgets/recent_conversation_card.dart';
import '../../../shared/widgets/suggestion_card.dart';
import '../../../shared/widgets/today_summary_card.dart';
import '../../../theme/app_spacing.dart';

/// Inicio — estructura vertical según prototipo funcional + estética premium Aris.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
        padding: const EdgeInsets.only(bottom: AppSpacing.homeSectionSpacing),
        children: [
          HomeBrandHeader(onAssistantTap: () => _openAssistant(context)),
          const SizedBox(height: AppSpacing.homeSectionSpacing),
          HomeGreetingCard(
            greeting: HomeMockContent.greetingForNow(),
            summary: HomeMockContent.summary,
          ),
          const SizedBox(height: AppSpacing.homeSectionSpacing),
          const SuggestionCard(message: HomeMockContent.suggestion),
          const SizedBox(height: AppSpacing.homeSectionSpacing),
          const TodaySummaryCard(
            events: HomeMockContent.events,
            tasks: HomeMockContent.tasks,
            notes: HomeMockContent.notes,
          ),
          const SizedBox(height: AppSpacing.homeSectionSpacing),
          const RecentConversationCard(),
        ],
      ),
    );
  }
}
