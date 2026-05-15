import 'package:flutter/material.dart';

import '../../../core/icon_from_key.dart';
import '../../../core/repositories/repositories.dart';
import '../../../shared/widgets/local_action_form_sheet.dart';
import '../../../shared/widgets/quick_action_card.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';

/// Pantalla de acciones del asistente **Aris** (solo demostración).
class AssistantScreen extends StatelessWidget {
  const AssistantScreen({super.key});

  void _onQuickActionTap(BuildContext context, String id) {
    switch (id) {
      case 'mock_act_task':
        LocalActionFormSheet.showTaskForm(context);
      case 'mock_act_event':
        LocalActionFormSheet.showEventForm(context);
      case 'mock_act_note':
        LocalActionFormSheet.showNoteForm(context);
      case 'mock_act_mail':
        LocalActionFormSheet.showMailForm(context);
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Acción simulada · sin servicio real')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final actions = Repositories.assistant.getQuickActions();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: scheme.surface.withValues(alpha: 0),
        foregroundColor: scheme.onPrimary,
        iconTheme: IconThemeData(color: scheme.onPrimary),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          style: IconButton.styleFrom(
            minimumSize: const Size(
              AppSpacing.minTouchTarget,
              AppSpacing.minTouchTarget,
            ),
          ),
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
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    scheme.primary,
                    scheme.primaryContainer,
                    scheme.secondary,
                  ]
                : [
                    scheme.primary,
                    AppColors.violetSoft,
                    scheme.secondary,
                  ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
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
                    onTap: () => _onQuickActionTap(context, a.id),
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
