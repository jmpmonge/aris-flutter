import 'package:flutter/material.dart';

import '../../../core/models/local_action_model.dart';
import '../../../core/services/local_action_service.dart';
import '../../../core/services/note_service.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/app_search_bar.dart';
import '../../../shared/widgets/local_action_card.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../theme/app_spacing.dart';

/// Notas — buscador, notas rápidas y lista **mock**.
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  void initState() {
    super.initState();
    LocalActionService.revision.addListener(_onArisActions);
  }

  @override
  void dispose() {
    LocalActionService.revision.removeListener(_onArisActions);
    super.dispose();
  }

  void _onArisActions() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final quick = NoteService.getQuickLabels();
    final recent = NoteService.getRecentNotes();
    final arisNotes =
        LocalActionService.getActionsByType(LocalActionType.note);

    return SafeArea(
      child: Column(
        key: const Key('tab_notes'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppHeader(
            title: 'Notas',
            subtitle: 'Captura rápida · sin sincronización real',
          ),
          const AppSearchBar(hintText: 'Buscar en notas…', readOnly: true),
          SectionTitle(
            title: 'Notas rápidas',
            actionLabel: 'Nueva nota',
            onAction: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nueva nota · solo demo')),
              );
            },
          ),
          SizedBox(
            height: AppSpacing.quickChipsStripHeight,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              scrollDirection: Axis.horizontal,
              itemCount: quick.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
              itemBuilder: (context, i) {
                return ActionChip(
                  label: Text(quick[i]),
                  side: BorderSide(
                    color: scheme.outline.withValues(alpha: 0.35),
                  ),
                  onPressed: () {},
                );
              },
            ),
          ),
          if (arisNotes.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Text(
                'Notas creadas por Aris',
                style: text.labelSmall?.copyWith(
                  letterSpacing: 1.1,
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(
              height: 132,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                scrollDirection: Axis.horizontal,
                itemCount: arisNotes.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, i) {
                  return SizedBox(
                    width: 280,
                    child: LocalActionCard(
                      action: arisNotes[i],
                      compact: true,
                    ),
                  );
                },
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Text(
              'Recientes',
              style: text.labelSmall?.copyWith(
                letterSpacing: 1.1,
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.fabStackClearance,
              ),
              itemCount: recent.length,
              itemBuilder: (context, i) {
                final n = recent[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.title, style: text.titleSmall),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          n.body,
                          style: text.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
