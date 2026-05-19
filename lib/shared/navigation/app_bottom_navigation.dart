import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Icono pestaña **Tareas** en barra inferior (`AppNavigationShell`, campo `icon`).
/// Compartido con el microencabezado TAREAS de [TodaySummaryCard] (v0.48.29).
const IconData kAppNavTasksTabIcon = Icons.task_alt_outlined;

/// Destino para [AppBottomNavigation].
class AppNavDestination {
  const AppNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Barra inferior Material 3 — en shell va dentro de cápsula (margen + [Material]).
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AppNavDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NavigationBar(
      height: AppSpacing.homeNavBarHeight,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      labelPadding: const EdgeInsets.only(top: 3),
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      indicatorColor: isDark
          ? const Color(0xFF303746).withValues(alpha: 0.92)
          : scheme.secondaryContainer.withValues(alpha: 0.75),
      destinations: [
        for (final d in destinations)
          NavigationDestination(
            icon: Icon(d.icon, size: AppSpacing.homeNavIconSize),
            selectedIcon: Icon(d.selectedIcon, size: AppSpacing.homeNavIconSize),
            label: d.label,
          ),
      ],
    );
  }
}
