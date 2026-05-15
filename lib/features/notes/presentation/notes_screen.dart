import 'package:flutter/material.dart';

import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/app_search_bar.dart';
import '../../../theme/app_spacing.dart';

/// Notas — buscador visual + tarjetas **mock**.
class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

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
            subtitle: 'Búsqueda local simulada · sin persistencia',
          ),
          const AppSearchBar(
            hintText: 'Buscar en notas (mock)',
            readOnly: true,
          ),
          const SizedBox(height: AppSpacing.sm),
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
