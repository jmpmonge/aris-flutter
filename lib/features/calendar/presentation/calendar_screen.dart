import 'package:flutter/material.dart';

import '../../../core/models/local_action_model.dart';
import '../../../core/services/calendar_service.dart';
import '../../../core/services/local_action_service.dart';
import 'calendar_body_views.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/local_action_card.dart';
import '../../../shared/widgets/local_action_empty_state.dart';
import '../../../shared/widgets/local_action_form_sheet.dart';
import '../../../theme/app_spacing.dart';

/// Calendario — vistas **Día / Semana / Mes** simuladas (sin calendario real).
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
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final arisEvents =
        LocalActionService.getActionsByType(LocalActionType.event);

    final calendarBody = switch (_view) {
      0 => CalendarDayView(events: CalendarService.getTodayEvents()),
      1 => CalendarWeekView(weekStart: mondayOfWeek(DateTime.now())),
      _ => const CalendarMonthView(),
    };

    return SafeArea(
      child: ListView(
        key: const Key('tab_calendar'),
        padding: const EdgeInsets.only(bottom: AppSpacing.fabStackClearance),
        children: [
          AppHeader(
            title: 'Calendario',
            subtitle: 'Planifica con calma · sin sincronización real',
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              switch (_view) {
                0 => 'Vista día · franjas horarias mock',
                1 => 'Vista semana · columnas por día mock',
                _ => 'Vista mes · cuadrícula y día seleccionado mock',
              },
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          calendarBody,
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              'Eventos creados por Aris',
              style: text.labelSmall?.copyWith(
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
