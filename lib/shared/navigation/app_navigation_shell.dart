import 'package:flutter/material.dart';

import '../../core/repositories/repositories.dart';
import '../../features/assistant/presentation/assistant_screen.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/notes/presentation/notes_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/tasks/presentation/tasks_screen.dart';
import '../layout/app_scaffold.dart';
import 'app_bottom_navigation.dart';
import '../widgets/app_floating_action_button.dart';
import '../widgets/chat_input_bar.dart';

/// Shell: **Inicio · Calendario · Notas · Tareas · Perfil** + barra de chat fija en Inicio.
class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({super.key});

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  int _tabIndex = 0;
  final _chatController = TextEditingController();

  static const List<Widget> _pages = [
    HomeScreen(),
    CalendarScreen(),
    NotesScreen(),
    TasksScreen(),
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

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _openAssistant() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const AssistantScreen()),
    );
  }

  void _onChatSend(String text) {
    Repositories.assistant.sendUserMessage(text);
    _chatController.clear();
  }

  void _onMicTap() {
    Repositories.assistant.sendVoicePendingNotice();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppScaffold(
      body: IndexedStack(index: _tabIndex, children: _pages),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_tabIndex == 0)
            ChatInputBar(
              controller: _chatController,
              hintText: 'Escribe a Aris…',
              onSend: _onChatSend,
              onMicTap: _onMicTap,
            ),
          Material(
            color: scheme.surface,
            child: Column(
              children: [
                Divider(
                  height: 1,
                  thickness: 1,
                  color: scheme.outline.withValues(alpha: 0.12),
                ),
                AppBottomNavigation(
                  currentIndex: _tabIndex,
                  onDestinationSelected: (i) => setState(() => _tabIndex = i),
                  destinations: _destinations,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabIndex == 0
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
