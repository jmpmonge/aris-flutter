import 'package:flutter/material.dart';

import '../../../core/icon_from_key.dart';
import '../../../core/services/assistant_service.dart';
import '../../../shared/widgets/quick_action_card.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';

/// Pantalla de acciones del asistente **Aris** (solo demostración).
class AssistantScreen extends StatelessWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final actions = AssistantService.getQuickActions();

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
          'Aris',
          style: text.titleLarge?.copyWith(color: scheme.onPrimary),
        ),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primary, AppColors.violetSoft, scheme.secondary],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            children: [
              Text(
                'Aris',
                style: text.displaySmall?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Te acompaño en tu día con calma. Esto es una bienvenida de ejemplo — sin IA conectada.',
                style: text.bodyLarge?.copyWith(
                  color: scheme.onPrimary.withValues(alpha: 0.9),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Acciones rápidas',
                style: text.titleMedium?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...actions.map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: QuickActionCard(
                    icon: iconFromKey(a.iconKey),
                    title: a.title,
                    subtitle: a.subtitle,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${a.title} · mock')),
                      );
                    },
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
