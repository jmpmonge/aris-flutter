import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Bloque **HOY**: eventos, tareas y notas compactas (mock).
class TodaySummaryCard extends StatelessWidget {
  const TodaySummaryCard({
    super.key,
    required this.events,
    required this.tasks,
    this.notes = const [],
  });

  final List<String> events;
  final List<String> tasks;
  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    Widget blockTitle(String t) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(
            t,
            style: text.labelSmall?.copyWith(
              letterSpacing: 1.1,
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        );

    Widget bulletRow(IconData icon, String line) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: scheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  line,
                  style: text.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.22)),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HOY',
                style: text.titleSmall?.copyWith(
                  letterSpacing: 1.4,
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              blockTitle('EVENTOS'),
              ...events.map((e) => bulletRow(Icons.event_available_outlined, e)),
              const SizedBox(height: AppSpacing.sm),
              blockTitle('TAREAS'),
              ...tasks.map((t) => bulletRow(Icons.radio_button_unchecked_rounded, t)),
              if (notes.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                blockTitle('NOTAS'),
                ...notes.map((n) => bulletRow(Icons.sticky_note_2_outlined, n)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
