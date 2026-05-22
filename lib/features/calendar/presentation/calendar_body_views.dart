import 'package:flutter/material.dart';

import '../../../core/repositories/calendar_repository.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../theme/app_spacing.dart';
import 'calendar_event_sheet.dart';

export 'widgets/calendar_day_view.dart';
export 'widgets/calendar_month_view.dart';
export 'widgets/calendar_week_view.dart';
export 'widgets/event_detail_sheet.dart';

bool calendarSameLocalDay(DateTime a, DateTime ref) {
  final al = DateTime(a.year, a.month, a.day);
  final rl = DateTime(ref.year, ref.month, ref.day);
  return al.year == rl.year && al.month == rl.month && al.day == rl.day;
}

/// Lunes de la semana [anchor] (local).
DateTime mondayOfWeek(DateTime anchor) {
  return DateTime(
    anchor.year,
    anchor.month,
    anchor.day,
  ).subtract(Duration(days: anchor.weekday - DateTime.monday));
}

/// Eventos `/events` con `date_text` no parseable a fecha civil (ej. «lunes»).
class CalendarTextualBackendEventsPanel extends StatelessWidget {
  const CalendarTextualBackendEventsPanel({
    super.key,
    required this.repository,
  });

  final CalendarRepository repository;

  @override
  Widget build(BuildContext context) {
    final extra = repository.textualOnlyDateBackendEvents;
    if (extra.isEmpty) return const SizedBox.shrink();

    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        Text(
          'Fecha en texto · servidor',
          style: text.labelSmall?.copyWith(
            letterSpacing: 0.8,
            color: scheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final e in extra)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${e.visibleDateLabel.isEmpty ? '—' : e.visibleDateLabel} · ${e.timeHm} · ${e.title}',
                          style: text.titleSmall,
                        ),
                        if (e.detail.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xxs),
                            child: Text(
                              e.detail,
                              style: text.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (calendarShouldShowBackendActions(e))
                    calendarBackendEventOverflowMenu(context, e),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
