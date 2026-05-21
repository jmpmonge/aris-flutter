import 'package:flutter/material.dart';

import '../../../core/models/event_model.dart';
import '../../../core/repositories/calendar_repository.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../theme/app_spacing.dart';
import 'calendar_event_sheet.dart';
import 'calendar_week_event_bubble.dart';

bool calendarSameLocalDay(DateTime a, DateTime ref) {
  final al = DateTime(a.year, a.month, a.day);
  final rl = DateTime(ref.year, ref.month, ref.day);
  return al.year == rl.year && al.month == rl.month && al.day == rl.day;
}

/// Franja horaria vertical (vista día, v0.49.10).
class CalendarDayView extends StatelessWidget {
  const CalendarDayView({super.key, required this.events});

  final List<EventModel> events;

  List<EventModel> get _civilTodayEvents {
    final n = DateTime.now();
    return events.where((e) {
      if (!e.hasCivilCalendarDate) return false;
      return calendarSameLocalDay(e.start, n);
    }).toList();
  }

  List<EventModel> get _textualDateEvents =>
      events.where((e) => !e.hasCivilCalendarDate).toList();

  static const int _firstHour = 7;
  static const int _lastHour = 21;

  EventModel? _eventStartingAtHour(int h) {
    for (final e in _civilTodayEvents) {
      if (e.start.hour == h) return e;
    }
    return null;
  }

  Widget _textualDatesSection(BuildContext context) {
    final textual = _textualDateEvents;
    if (textual.isEmpty) return const SizedBox.shrink();
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
        Text(
          'Día textual del backend («lunes», «mañana»…): no se coloca como «hoy» civil.',
          style: text.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final e in textual)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${e.visibleDateLabel.isEmpty ? '—' : e.visibleDateLabel} · ${e.timeHm} · ${e.title}',
                          style: text.titleSmall,
                        ),
                        if (e.detail.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: AppSpacing.xxs,
                            ),
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
                ),
                if (calendarShouldShowBackendActions(e))
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.xs),
                    child: calendarBackendEventOverflowMenu(context, e),
                  ),
              ],
            ),
          ),
      ],
    );
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
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppCard(
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
                            ),
                          ),
                          if (calendarShouldShowBackendActions(match))
                            Padding(
                              padding: const EdgeInsets.only(
                                left: AppSpacing.xs,
                              ),
                              child:
                                  calendarBackendEventOverflowMenu(context, match),
                            ),
                        ],
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
          for (int h = _firstHour; h <= _lastHour; h++) hourRow(h),
          _textualDatesSection(context),
        ],
      ),
    );
  }
}

/// Rejilla horaria semanal + ficha de detalle inferior al pulsar (v0.49.9).
class CalendarWeekView extends StatefulWidget {
  const CalendarWeekView({
    super.key,
    required this.weekStart,
    required this.calendarRepository,
  });

  final DateTime weekStart;

  final CalendarRepository calendarRepository;

  static const weekdayShortLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  State<CalendarWeekView> createState() => _CalendarWeekViewState();
}

class _CalendarWeekViewState extends State<CalendarWeekView> {
  String? _selectedEventId;

  static const int _dayCount = 7;

  /// Misma ventana horaria que la vista Día.
  static const int _firstHour = 7;
  static const int _lastHour = 21;

  /// Altura fija por franja: evita overflow vertical en columnas estrechas.
  static const double _kWeekSlotHeight = 32;

  static EventModel? _eventStartingAtHour(List<EventModel> dayEvents, int hour) {
    for (final e in dayEvents) {
      if (!e.hasCivilCalendarDate) continue;
      if (e.start.hour == hour) return e;
    }
    return null;
  }

  Widget _weekDayHeader({
    required BuildContext context,
    required int dayIndex,
    required DateTime day,
    required bool isToday,
  }) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isToday
            ? scheme.primaryContainer.withValues(alpha: 0.4)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: isToday
              ? scheme.primary.withValues(alpha: 0.35)
              : scheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
        child: Column(
          children: [
            Text(
              CalendarWeekView.weekdayShortLabels[dayIndex],
              style: text.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${day.day}',
              style: text.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.1,
                color: isToday ? scheme.primary : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onWeekEventTap(String eventId) {
    setState(() {
      _selectedEventId = _selectedEventId == eventId ? null : eventId;
    });
  }

  EventModel? _findSelectedEvent(List<List<EventModel>> eventsByDay) {
    final id = _selectedEventId;
    if (id == null) return null;
    for (final day in eventsByDay) {
      for (final e in day) {
        if (e.id == id) return e;
      }
    }
    return null;
  }

  Widget _weekEventBlock(BuildContext context, EventModel event) {
    final isSelected = _selectedEventId == event.id;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onWeekEventTap(event.id),
        borderRadius: BorderRadius.circular(6),
        child: CalendarWeekEventBubble(
          event: event,
          isSelected: isSelected,
        ),
      ),
    );
  }

  /// Misma presentación que la tarjeta de evento en [CalendarDayView].
  Widget _weekSelectedEventDetail(BuildContext context, EventModel event) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
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
                    '${event.timeHm} · ${event.title}',
                    style: text.titleSmall,
                  ),
                  if (event.detail.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xxs),
                      child: Text(
                        event.detail,
                        style: text.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (calendarShouldShowBackendActions(event))
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xs),
                child: calendarBackendEventOverflowMenu(context, event),
              ),
          ],
        ),
      ),
    );
  }

  Widget _weekHourSlot({
    required BuildContext context,
    required int hour,
    required List<EventModel> dayEvents,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final match = _eventStartingAtHour(dayEvents, hour);

    return SizedBox(
      height: _kWeekSlotHeight,
      child: ClipRect(
        child: Container(
          padding: const EdgeInsets.only(left: AppSpacing.xxs),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: scheme.outline.withValues(alpha: 0.22),
              ),
            ),
          ),
          alignment: Alignment.centerLeft,
          child: match == null ? null : _weekEventBlock(context, match),
        ),
      ),
    );
  }

  Widget _weekHourRow({
    required BuildContext context,
    required int hour,
    required List<List<EventModel>> eventsByDay,
  }) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppSpacing.calendarTimeColumnWidth,
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: text.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.2,
              ),
            ),
          ),
          for (var i = 0; i < _dayCount; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i == 0 ? AppSpacing.xxs : 2),
                child: _weekHourSlot(
                  context: context,
                  hour: hour,
                  dayEvents: eventsByDay[i],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final eventsByDay = List.generate(_dayCount, (i) {
      final d = widget.weekStart.add(Duration(days: i));
      return widget.calendarRepository.getWeekEvents(d);
    });
    final selected = _findSelectedEvent(eventsByDay);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: AppSpacing.calendarTimeColumnWidth),
              for (var i = 0; i < _dayCount; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: i == 0 ? AppSpacing.xxs : 2),
                    child: _weekDayHeader(
                      context: context,
                      dayIndex: i,
                      day: widget.weekStart.add(Duration(days: i)),
                      isToday: calendarSameLocalDay(
                        widget.weekStart.add(Duration(days: i)),
                        now,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (int h = _firstHour; h <= _lastHour; h++)
            _weekHourRow(
              context: context,
              hour: h,
              eventsByDay: eventsByDay,
            ),
          if (selected != null)
            _weekSelectedEventDetail(context, selected),
          CalendarTextualBackendEventsPanel(
            repository: widget.calendarRepository,
          ),
        ],
      ),
    );
  }
}

/// Cuadrícula mensual + lista del día seleccionado (mock).
class CalendarMonthView extends StatefulWidget {
  const CalendarMonthView({
    super.key,
    required this.calendarRepository,
  });

  /// Fuente mes/día desde backend cuando existan datos suficientes.
  final CalendarRepository calendarRepository;

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

    final selectedEvents =
        widget.calendarRepository.getMonthEvents(_month, _selectedDay);

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
              final hasDot = widget.calendarRepository.getMonthDayHasEvent(
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
                      if (calendarShouldShowBackendActions(e))
                        calendarBackendEventOverflowMenu(context, e),
                    ],
                  ),
                ),
              ),
            ),
          CalendarTextualBackendEventsPanel(
            repository: widget.calendarRepository,
          ),
        ],
      ),
    );
  }
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

/// Lunes de la semana [anchor] (local).
DateTime mondayOfWeek(DateTime anchor) {
  return DateTime(
    anchor.year,
    anchor.month,
    anchor.day,
  ).subtract(Duration(days: anchor.weekday - DateTime.monday));
}
