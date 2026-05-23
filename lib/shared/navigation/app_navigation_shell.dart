import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/repositories/repositories.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/notes/presentation/notes_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/tasks/presentation/tasks_screen.dart';
import '../layout/app_scaffold.dart';
import '../../theme/app_spacing.dart';
import 'app_bottom_navigation.dart';

/// Shell v1: **Inicio · Calendario · Tareas · Notas · Perfil** (v0.49.40).
/// Mail queda fuera de la navegación visible — módulo futuro.
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
        onOpenNotes: _goToNotesTab,
      ),
      const CalendarScreen(),
      const TasksScreen(),
      const NotesScreen(),
      ProfileScreen(onClose: () => _onTabSelected(_tabHome)),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(Repositories.prefetchBackendReads());
    });
  }

  static const int _tabHome = 0;
  static const int _tabCalendar = 1;
  static const int _tabTasks = 2;
  static const int _tabNotes = 3;
  static const int _tabProfile = 4;

  static const List<int> _mainSectionTabs = [
    _tabHome,
    _tabCalendar,
    _tabTasks,
    _tabNotes,
    _tabProfile,
  ];

  void _goToCalendarTab() => _onTabSelected(_tabCalendar);

  void _goToTasksTab() => _onTabSelected(_tabTasks);

  void _goToNotesTab() => _onTabSelected(_tabNotes);

  void _onTabSelected(int index) {
    assert(_mainSectionTabs.contains(index));
    setState(() => _tabIndex = index);
    if (index == _tabHome) {
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
      icon: Icons.task_alt_outlined,
      selectedIcon: Icons.task_alt_rounded,
      label: 'Tareas',
    ),
    AppNavDestination(
      icon: kAppNavNotesTabIcon,
      selectedIcon: Icons.note_alt_rounded,
      label: 'Notas',
    ),
    AppNavDestination(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Perfil',
    ),
  ];

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
    );
  }
}
