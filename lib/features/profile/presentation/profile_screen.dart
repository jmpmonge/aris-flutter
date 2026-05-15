import 'package:flutter/material.dart';

import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../theme/app_spacing.dart';
import '../../settings/presentation/settings_screen.dart';

/// Perfil — usuario, opciones y **versión** (mock).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    final options = [
      (Icons.person_rounded, 'Cuenta', 'Datos de perfil simulados'),
      (Icons.tune_rounded, 'Preferencias', 'Notificaciones, idioma…'),
      (Icons.hub_outlined, 'Integraciones', 'Próximamente · sin APIs'),
      (Icons.shield_outlined, 'Privacidad', 'Políticas de ejemplo'),
      (Icons.help_outline_rounded, 'Ayuda', 'Centro de ayuda mock'),
    ];

    return SafeArea(
      child: ListView(
        key: const Key('tab_profile'),
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          const AppHeader(
            title: 'Perfil',
            subtitle: 'Tu espacio en Aris',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: scheme.primaryContainer,
                    child: Text(
                      'J',
                      style: text.headlineSmall?.copyWith(color: scheme.onPrimaryContainer),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('José', style: text.titleMedium),
                        Text(
                          'jose@ejemplo.aris (simulado)',
                          style: text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...options.map(
            (o) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xxs,
              ),
              child: AppCard(
                onTap: () {
                  if (o.$2 == 'Cuenta') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cuenta · solo mock')),
                    );
                    return;
                  }
                  if (o.$2 == 'Preferencias') {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${o.$2} · solo mock')),
                  );
                },
                child: Row(
                  children: [
                    Icon(o.$1, color: scheme.primary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(o.$2, style: text.titleSmall),
                          Text(
                            o.$3,
                            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Versión',
                    style: text.labelSmall?.copyWith(
                      color: scheme.secondary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Aris · v0.25.0 (build de demostración)',
                    style: text.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
