import 'package:flutter/material.dart';

import 'shared/widgets/app_bottom_navigation.dart';
import 'shared/widgets/app_card.dart';
import 'shared/widgets/app_floating_action_button.dart';
import 'shared/widgets/app_header.dart';
import 'shared/widgets/app_search_bar.dart';
import 'shared/widgets/empty_state_card.dart';
import 'shared/widgets/section_title.dart';
import 'theme/app_spacing.dart';
import 'theme/app_theme.dart';

/// Raíz de la aplicación.
class ArisApp extends StatelessWidget {
  const ArisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aris',
      theme: AppTheme.light(),
      home: const _DesignSystemPreview(),
    );
  }
}

/// Placeholder mínimo que **usa** los componentes del design system (no es pantalla de producto).
class _DesignSystemPreview extends StatefulWidget {
  const _DesignSystemPreview();

  @override
  State<_DesignSystemPreview> createState() => _DesignSystemPreviewState();
}

class _DesignSystemPreviewState extends State<_DesignSystemPreview> {
  int _navIndex = 0;

  static const _navDestinations = [
    AppNavDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Inicio',
    ),
    AppNavDestination(
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_today_rounded,
      label: 'Agenda',
    ),
    AppNavDestination(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Perfil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          key: const Key('design_system_preview'),
          children: [
            const AppHeader(
              title: 'Aris',
              subtitle: 'Clara · vista previa del sistema visual (mock)',
            ),
            const SizedBox(height: AppSpacing.sm),
            const AppSearchBar(
              readOnly: true,
              hintText: 'Buscar en tu día (simulado)',
            ),
            SectionTitle(
              title: 'Explorar',
              actionLabel: 'Ver todo',
              onAction: () {},
            ),
            const _DemoCardRow(),
            const SizedBox(height: AppSpacing.sm),
            EmptyStateCard(
              icon: Icons.inbox_rounded,
              title: 'Nada por aquí aún',
              message:
                  'Clara preparará sugerencias cuando conectemos tus datos. Por ahora es solo diseño.',
              actionLabel: 'Entendido',
              onAction: () {},
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: _navDestinations,
      ),
      floatingActionButton: AppFloatingActionButton(
        heroTag: 'preview_fab',
        tooltip: 'Acción principal (mock)',
        icon: Icons.add_rounded,
        onPressed: () {},
      ),
    );
  }
}

class _DemoCardRow extends StatelessWidget {
  const _DemoCardRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: AppCard(
        child: Text(
          'Tarjeta de ejemplo · datos simulados',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
