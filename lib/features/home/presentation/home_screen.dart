import 'package:flutter/material.dart';

import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../theme/app_spacing.dart';

/// Inicio — datos **simulados** (sin backend).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: ListView(
        key: const Key('tab_home'),
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          const AppHeader(
            title: 'Hola, José',
            subtitle: 'Aquí va un resumen tranquilo de tu día · mock',
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              'Hoy, viernes — pocos compromisos, espacio para lo importante.',
              style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const SectionTitle(title: 'Próxima cita'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.event_rounded, color: scheme.primary, size: 22),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Revisión médica anual', style: text.titleSmall),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '15:30 · Centro de salud Norte (simulado)',
                    style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          const SectionTitle(title: 'Tareas de hoy'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('3 pendientes', style: text.titleSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '• Llamar a mamá\n' '• Pagar parking\n' '• Enviar borrador (mock)',
                    style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          const SectionTitle(title: 'Notas recientes'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ideas sueltas', style: text.titleSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '“Regalo cumple Ana” · “Playlist viaje” (mock)',
                    style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
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
