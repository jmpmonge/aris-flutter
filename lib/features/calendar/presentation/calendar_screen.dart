import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/local_action_model.dart';
import '../../../core/repositories/repositories.dart';
import '../../../core/services/local_action_service.dart';
import 'calendar_body_views.dart';
import 'calendar_event_sheet.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/local_action_card.dart';
import '../../../shared/widgets/local_action_empty_state.dart';
import '../../../shared/widgets/local_action_form_sheet.dart';
import '../../../theme/app_spacing.dart';

/// Calendario — vistas Día / Semana / Mes (v0.49.4: reserva inferior Semana).
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _view = 0;

  @override
  void initState() {
    super.initState();
    unawaited(Repositories.calendar.refreshFromBackend());
    LocalActionService.revision.addListener(_onArisActions);
    Repositories.calendar.readRevision.addListener(_onCalendarReads);
  }

  @override
  void dispose() {
    Repositories.calendar.readRevision.removeListener(_onCalendarReads);
    LocalActionService.revision.removeListener(_onArisActions);
    super.dispose();
  }

  void _onCalendarReads() => setState(() {});

  void _onArisActions() {
    if (mounted) setState(() {});
  }

  /// Aire inferior del scroll: Semana necesita más reserva por FAB centrado.
  double _listBottomPadding(BuildContext context) {
    var pad = AppSpacing.fabStackClearance;
    if (_view == 1) {
      pad += AppSpacing.calendarWeekBottomClearanceExtra;
      pad += MediaQuery.paddingOf(context).bottom;
    }
    return pad;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final arisEvents =
        LocalActionService.getActionsByType(LocalActionType.event);

    final calendarBody = switch (_view) {
      0 => CalendarDayView(
          events: Repositories.calendar.getTodayEvents(),
        ),
      1 => CalendarWeekView(
          weekStart: mondayOfWeek(DateTime.now()),
          calendarRepository: Repositories.calendar,
        ),
      _ => CalendarMonthView(calendarRepository: Repositories.calendar),
    };

    return SafeArea(
      top: true,
      bottom: false,
      child: ListView(
        key: const Key('tab_calendar'),
        padding: EdgeInsets.only(bottom: _listBottomPadding(context)),
        children: [
          AppHeader(
            title: 'Calendario',
            subtitle: _view == 1
                ? null
                : 'Servidor PATCH/DELETE cuando GET /events OK · datos locales como respaldo',
            trailing: IconButton.filledTonal(
              onPressed: () => LocalActionFormSheet.showEventForm(context),
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Nuevo evento',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Día')),
                ButtonSegment(value: 1, label: Text('Semana')),
                ButtonSegment(value: 2, label: Text('Mes')),
              ],
              selected: {_view},
              onSelectionChanged: (s) => setState(() => _view = s.first),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_view != 1) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                switch (_view) {
                  0 => 'Vista día · franjas horarias mock',
                  _ => 'Vista mes · cuadrícula y día seleccionado mock',
                },
                style: text.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          calendarBody,
          if (_view == 1) const SizedBox(height: AppSpacing.lg),
          const SizedBox(height: AppSpacing.lg),
          if (Repositories.calendar.readsFromBackend &&
              Repositories.calendar.allBackendEvents.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                'Todos los eventos del servidor',
                style: text.labelSmall?.copyWith(
                  letterSpacing: 0.8,
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...Repositories.calendar.allBackendEvents.map((e) {
              final dateLabel = e.dateIso?.isNotEmpty == true
                  ? e.dateIso!
                  : e.visibleDateLabel.isNotEmpty
                  ? e.visibleDateLabel
                  : '—';
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.title,
                              style: text.titleSmall,
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              '$dateLabel · ${e.timeHm}',
                              style: text.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            if (e.detail.isNotEmpty)
                              Text(
                                e.detail,
                                style: text.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant.withValues(
                                    alpha: 0.7,
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
              );
            }),
            const SizedBox(height: AppSpacing.sm),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              'Eventos creados por Aris',
              style: _view == 1
                  ? text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    )
                  : text.labelSmall?.copyWith(
                      letterSpacing: 0.8,
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (arisEvents.isEmpty)
            const LocalActionEmptyState(
              message:
                  'Nada aquí. Usa + arriba o escribe en Inicio con «reunión» o «mañana…».',
            )
          else
            ...List.generate(arisEvents.length, (i) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: LocalActionCard(action: arisEvents[i]),
              );
            }),
        ],
      ),
    );
  }
}
