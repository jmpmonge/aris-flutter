import 'package:flutter/material.dart';

import '../../core/services/local_action_service.dart';
import '../../theme/app_spacing.dart';
import 'local_action_card.dart';

/// Indica en Inicio la última acción local simulada creada por Aris (si existe).
class LatestArisActionSection extends StatelessWidget {
  const LatestArisActionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final latest = LocalActionService.getMostRecentAction();
    if (latest == null) return const SizedBox.shrink();

    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Última acción de Aris',
            style: text.labelSmall?.copyWith(
              letterSpacing: 1.1,
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          LocalActionCard(action: latest, compact: true),
        ],
      ),
    );
  }
}
