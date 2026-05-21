import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/repositories/repositories.dart';
import '../../features/assistant/presentation/assistant_screen.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/mail/presentation/mail_screen.dart';
import '../../features/notes/presentation/notes_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/tasks/presentation/tasks_screen.dart';
import '../layout/app_scaffold.dart';
import '../../theme/app_spacing.dart';
import 'app_bottom_navigation.dart';
import '../widgets/app_floating_action_button.dart';

/// Shell: **Inicio · Calendario · Notas · Tareas · Perfil** (input Aris en Home v0.48.43).
class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({super.key});

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  int _tabIndex = 0;
  final _homeKey = GlobalKey<HomeScreenState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(
        key: _homeKey,
        onOpenCalendar: _goToCalendarTab,
        onOpenTasks: _goToTasksTab,
        onOpenMail: _openMailScreen,
      ),
      const CalendarScreen(),
      const NotesScreen(),
      const TasksScreen(),
      const ProfileScreen(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(Repositories.prefetchBackendReads());
    });
  }

  void _goToCalendarTab() => _onTabSelected(1);

  void _goToTasksTab() => _onTabSelected(3);

  void _openMailScreen() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const MailScreen()),
    );
  }

  void _onTabSelected(int index) {
    setState(() => _tabIndex = index);
    if (index == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _homeKey.currentState?.scrollToTop();
      });
    }
  }

  static const List<AppNavDestination> _destinations = [
    AppNavDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Inicio',
    ),
    AppNavDestination(
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_today_rounded,
      label: 'Calendario',
    ),
    AppNavDestination(
      icon: Icons.note_alt_outlined,
      selectedIcon: Icons.note_alt_rounded,
      label: 'Notas',
    ),
    AppNavDestination(
      icon: Icons.task_alt_outlined,
      selectedIcon: Icons.task_alt_rounded,
      label: 'Tareas',
    ),
    AppNavDestination(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Perfil',
    ),
  ];

  void _openAssistant() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const AssistantScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppScaffold(
      body: IndexedStack(index: _tabIndex, children: _pages),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              14,
              4,
              14,
              8,
            ),
            child: Material(
              color: scheme.surface,
              elevation: 1,
              shadowColor: scheme.shadow.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.homeNavBarRadius),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 2,
                  horizontal: AppSpacing.homeNavBarHorizontalPadding,
                ),
                child: AppBottomNavigation(
                  currentIndex: _tabIndex,
                  onDestinationSelected: _onTabSelected,
                  destinations: _destinations,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _tabIndex == 0 || _tabIndex == 1
          ? null
          : AppFloatingActionButton(
              heroTag: 'shell_assistant_fab',
              tooltip: 'Hablar con Aris',
              icon: Icons.auto_awesome_rounded,
              onPressed: _openAssistant,
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
