import 'package:flutter/material.dart';

import '../../features/assistant/presentation/assistant_screen.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/mail/presentation/mail_screen.dart';
import '../../features/notes/presentation/notes_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../layout/app_scaffold.dart';
import '../widgets/app_floating_action_button.dart';
import 'app_bottom_navigation.dart';

/// Contenedor principal: **5 pestañas** + FAB **centrado** para abrir el asistente (**AssistantScreen**).
class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({super.key});

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  int _tabIndex = 0;

  static const List<Widget> _pages = [
    HomeScreen(),
    CalendarScreen(),
    NotesScreen(),
    MailScreen(),
    ProfileScreen(),
  ];

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
      icon: Icons.mail_outlined,
      selectedIcon: Icons.mail_rounded,
      label: 'Mail',
    ),
    AppNavDestination(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Perfil',
    ),
  ];

  void _openAssistant() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const AssistantScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: _destinations,
      ),
      floatingActionButton: AppFloatingActionButton(
        heroTag: 'shell_assistant_fab',
        tooltip: 'Hablar con Aris',
        icon: Icons.auto_awesome_rounded,
        onPressed: _openAssistant,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
