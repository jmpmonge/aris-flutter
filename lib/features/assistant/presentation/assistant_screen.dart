import 'package:flutter/material.dart';

import '../../../shared/widgets/app_card.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';

/// Clara — acciones rápidas **premium** (sin LLM ni audio real).
class AssistantScreen extends StatelessWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final actions = [
      (Icons.mic_rounded, 'Hablar con Clara', 'Dictado simulado'),
      (Icons.add_task_rounded, 'Nueva tarea', 'Añadir a la lista mock'),
      (Icons.event_available_rounded, 'Nuevo evento', 'Sin calendario real'),
      (Icons.note_add_rounded, 'Nueva nota', 'Borrador local ficticio'),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onPrimary,
        iconTheme: IconThemeData(color: scheme.onPrimary),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Clara',
          style: text.titleLarge?.copyWith(color: scheme.onPrimary),
        ),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary,
              AppColors.violetSoft,
              scheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            children: [
              Text(
                '¿Qué te gustaría hacer?',
                style: text.headlineSmall?.copyWith(color: scheme.onPrimary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Accesos rápidos · todo es demostración',
                style: text.bodyMedium?.copyWith(
                  color: scheme.onPrimary.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ...actions.map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppCard(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${a.$2} · mock')),
                      );
                    },
                    semanticLabel: a.$2,
                    child: Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: scheme.onPrimary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            child: Icon(a.$1, color: scheme.onPrimary, size: 26),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.$2,
                                style: text.titleSmall?.copyWith(color: scheme.onSurface),
                              ),
                              Text(
                                a.$3,
                                style: text.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
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
            ],
          ),
        ),
      ),
    );
  }
}
