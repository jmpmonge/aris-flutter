import 'package:flutter/material.dart';

import '../../../shared/layout/app_scaffold.dart';
import '../../../shared/navigation/app_bottom_navigation.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_floating_action_button.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../theme/app_spacing.dart';

/// Vista **solo para validar** el design system; no es la home final del producto.
class HomePreviewScreen extends StatefulWidget {
  const HomePreviewScreen({super.key});

  @override
  State<HomePreviewScreen> createState() => _HomePreviewScreenState();
}

class _HomePreviewScreenState extends State<HomePreviewScreen> {
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
      icon: Icons.mail_outlined,
      selectedIcon: Icons.mail_rounded,
      label: 'Correo',
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
      body: SafeArea(
        child: ListView(
          key: const Key('home_preview_screen'),
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          children: [
            AppHeader(
              title: 'Hola, José',
              subtitle: 'Un resumen sencillo de tu día · datos de ejemplo',
              trailing: AppIconButton(
                icon: Icons.notifications_outlined,
                tooltip: 'Avisos (mock)',
                onPressed: () {},
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: AppCard(
                child: _PreviewBlock(
                  icon: Icons.event_rounded,
                  iconColor: scheme.primary,
                  title: 'Próxima cita',
                  headline: 'Revisión anual',
                  detail: 'Miércoles 17 · 15:30 · Centro de salud (simulado)',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: AppCard(
                child: _PreviewBlock(
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: scheme.secondary,
                  title: 'Tareas',
                  headline: '3 pendientes',
                  detail: 'Llamar a papá · factura luz · preparar maleta (mock)',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: AppCard(
                child: _PreviewBlock(
                  icon: Icons.note_alt_outlined,
                  iconColor: scheme.tertiary,
                  title: 'Notas',
                  headline: 'Ideas recientes',
                  detail: '“Propuesta reunión martes” · “Recordar regalo” (mock)',
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: _navDestinations,
      ),
      floatingActionButton: AppFloatingActionButton(
        heroTag: 'home_preview_fab',
        tooltip: 'Acción rápida (mock)',
        icon: Icons.add_rounded,
        onPressed: () {},
      ),
    );
  }
}

class _PreviewBlock extends StatelessWidget {
  const _PreviewBlock({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.headline,
    required this.detail,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String headline;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(width: AppSpacing.sm),
            Text(title, style: theme.textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(headline, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          detail,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
