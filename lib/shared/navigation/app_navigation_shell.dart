import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/repositories/repositories.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/mail/presentation/mail_screen.dart';
import '../../features/notes/presentation/notes_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/tasks/presentation/tasks_screen.dart';
import '../layout/app_scaffold.dart';
import '../../theme/app_spacing.dart';
import 'app_bottom_navigation.dart';

/// Shell: **Inicio · Calendario · Tareas · Notas · Mail** (v0.49.30–31).
class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({super.key});

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  int _tabIndex = 0;
  bool _profileOpen = false;
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
        onOpenMail: _goToMailTab,
        onOpenSettings: _openProfileInShell,
      ),
      const CalendarScreen(),
      const TasksScreen(),
      const NotesScreen(),
      const MailScreen(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(Repositories.prefetchBackendReads());
    });
  }

  static const int _tabHome = 0;
  static const int _tabCalendar = 1;
  static const int _tabTasks = 2;
  static const int _tabNotes = 3;
  static const int _tabMail = 4;

  static const List<int> _mainSectionTabs = [
    _tabHome,
    _tabCalendar,
    _tabTasks,
    _tabNotes,
    _tabMail,
  ];

  void _goToCalendarTab() => _onTabSelected(_tabCalendar);

  void _goToTasksTab() => _onTabSelected(_tabTasks);

  void _goToMailTab() => _onTabSelected(_tabMail);

  /// Perfil auxiliar dentro del shell: botonera sigue visible (v0.49.31).
  void _openProfileInShell() {
    setState(() => _profileOpen = true);
  }

  void _closeProfileToHome() {
    setState(() {
      _profileOpen = false;
      _tabIndex = _tabHome;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeKey.currentState?.scrollToTop();
    });
  }

  void _onTabSelected(int index) {
    assert(_mainSectionTabs.contains(index));
    setState(() {
      _tabIndex = index;
      _profileOpen = false;
    });
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
      icon: Icons.note_alt_outlined,
      selectedIcon: Icons.note_alt_rounded,
      label: 'Notas',
    ),
    AppNavDestination(
      icon: Icons.mail_outline_rounded,
      selectedIcon: Icons.mail_rounded,
      label: 'Mail',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppScaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          IndexedStack(index: _tabIndex, children: _pages),
          if (_profileOpen)
            ColoredBox(
              color: scheme.surface,
              child: ProfileScreen(onClose: _closeProfileToHome),
            ),
        ],
      ),
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
