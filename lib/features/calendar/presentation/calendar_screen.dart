import 'package:flutter/material.dart';

import '../../../core/services/calendar_service.dart';
import 'calendar_body_views.dart';
import '../../../shared/widgets/app_header.dart';
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
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

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
          const AppHeader(
            title: 'Calendario',
            subtitle: 'Planifica con calma · sin sincronización real',
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
        ],
      ),
    );
  }
}
