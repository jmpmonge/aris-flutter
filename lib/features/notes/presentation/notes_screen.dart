import 'package:flutter/material.dart';

import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/app_search_bar.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../theme/app_spacing.dart';

/// Notas — buscador, notas rápidas y lista **mock**.
class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  static const _quick = ['Compra', 'Ideas viaje', 'Libros'];
  static const _notes = [
    ('Ideas reunión', 'Bullet: timing, presupuesto, follow-up…'),
    ('Libros 2026', 'Ficción · ensayo · cómic (lista simulada)'),
    ('Lista compras', 'Pan, leche, fruta…'),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        key: const Key('tab_notes'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppHeader(
            title: 'Notas',
            subtitle: 'Captura rápida · sin sincronización real',
          ),
          const AppSearchBar(
            hintText: 'Buscar en notas…',
            readOnly: true,
          ),
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
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              scrollDirection: Axis.horizontal,
              itemCount: _quick.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
              itemBuilder: (context, i) {
                return ActionChip(
                  label: Text(_quick[i]),
                  side: BorderSide(color: scheme.outline.withValues(alpha: 0.35)),
                  onPressed: () {},
                );
              },
            ),
          ),
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
                100,
              ),
              itemCount: _notes.length,
              itemBuilder: (context, i) {
                final n = _notes[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.$1, style: text.titleSmall),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          n.$2,
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
