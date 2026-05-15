import 'package:flutter/material.dart';

import '../../../core/models/event_model.dart';
import '../../../core/services/calendar_service.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../theme/app_spacing.dart';

/// Franja horaria vertical (vista día) — eventos mock por hora.
class CalendarDayView extends StatelessWidget {
  const CalendarDayView({super.key, required this.events});

  final List<EventModel> events;

  static const int _firstHour = 7;
  static const int _lastHour = 21;

  EventModel? _eventStartingAtHour(int h) {
    for (final e in events) {
      if (e.start.hour == h) return e;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    Widget hourRow(int h) {
      final match = _eventStartingAtHour(h);
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: AppSpacing.calendarTimeColumnWidth,
              child: Text(
                '${h.toString().padLeft(2, '0')}:00',
                style: text.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: scheme.outline.withValues(alpha: 0.25),
                    ),
                  ),
                ),
                child: match != null
                    ? AppCard(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${match.timeHm} · ${match.title}',
                              style: text.titleSmall,
                            ),
                            Text(
                              match.detail,
                              style: text.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(height: AppSpacing.minTouchTarget * 0.45),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hoy · franjas horarias (mock)',
            style: text.labelSmall?.copyWith(
              letterSpacing: 0.8,
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (int h = _firstHour; h <= _lastHour; h++) hourRow(h),
        ],
      ),
    );
  }
}

/// Cabecera semanal + columnas por día (mock).
class CalendarWeekView extends StatelessWidget {
  const CalendarWeekView({super.key, required this.weekStart});

  final DateTime weekStart;

  static const weekdayShortLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Semana · reparto simulado',
            style: text.labelSmall?.copyWith(
              letterSpacing: 0.8,
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(7, (i) {
              final d = weekStart.add(Duration(days: i));
              final events = CalendarService.getWeekEvents(d);
              final isToday =
                  d.year == DateTime.now().year &&
                  d.month == DateTime.now().month &&
                  d.day == DateTime.now().day;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs / 2),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: isToday
                          ? scheme.primaryContainer.withValues(alpha: 0.35)
                          : scheme.surfaceContainerHighest.withValues(
                              alpha: 0.25,
                            ),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: scheme.outline.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      child: Column(
                        children: [
                          Text(
                            weekdayShortLabels[i],
                            style: text.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: scheme.primary,
                            ),
                          ),
                          Text(
                            '${d.day}',
                            style: text.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          if (events.isEmpty)
                            Text(
                              '—',
                              style: text.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            )
                          else
                            ...events.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.xxs,
                                ),
                                child: Text(
                                  e.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.bodySmall?.copyWith(height: 1.2),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Cuadrícula mensual + lista del día seleccionado (mock).
class CalendarMonthView extends StatefulWidget {
  const CalendarMonthView({super.key});

  @override
  State<CalendarMonthView> createState() => _CalendarMonthViewState();
}

class _CalendarMonthViewState extends State<CalendarMonthView> {
  late DateTime _month;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _month = DateTime(n.year, n.month);
    _selectedDay = n.day;
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    final first = DateTime(_month.year, _month.month);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leading = first.weekday - DateTime.monday;
    final totalCells = ((leading + daysInMonth + 6) ~/ 7) * 7;

    final selectedEvents = CalendarService.getMonthEvents(_month, _selectedDay);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mes · ${_month.year}/${_month.month.toString().padLeft(2, '0')}',
            style: text.labelSmall?.copyWith(
              letterSpacing: 0.8,
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: CalendarWeekView.weekdayShortLabels
                .map(
                  (l) => Expanded(
                    child: Center(
                      child: Text(
                        l,
                        style: text.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.xs),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: AppSpacing.xxs,
              crossAxisSpacing: AppSpacing.xxs,
              childAspectRatio: 1.1,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              final dayNum = index - leading + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const SizedBox.shrink();
              }
              final hasDot = CalendarService.getMonthDayHasEvent(
                _month,
                dayNum,
              );
              final selected = dayNum == _selectedDay;
              final isToday =
                  _month.year == DateTime.now().year &&
                  _month.month == DateTime.now().month &&
                  dayNum == DateTime.now().day;

              return InkWell(
                onTap: () => setState(() => _selectedDay = dayNum),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: selected
                        ? scheme.primary.withValues(alpha: 0.2)
                        : isToday
                        ? scheme.tertiaryContainer.withValues(alpha: 0.4)
                        : null,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(
                      color: selected
                          ? scheme.primary
                          : scheme.outline.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: text.titleSmall?.copyWith(
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
                      if (hasDot)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: scheme.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Día $_selectedDay · detalle (mock)',
            style: text.labelSmall?.copyWith(
              letterSpacing: 0.8,
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (selectedEvents.isEmpty)
            Text(
              'Sin eventos simulados para este día.',
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            )
          else
            ...selectedEvents.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: AppSpacing.calendarTimeColumnWidth,
                        child: Text(e.timeHm, style: text.labelLarge),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.title, style: text.titleSmall),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(e.detail, style: text.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Lunes de la semana [anchor] (local).
DateTime mondayOfWeek(DateTime anchor) {
  return DateTime(
    anchor.year,
    anchor.month,
    anchor.day,
  ).subtract(Duration(days: anchor.weekday - DateTime.monday));
}
