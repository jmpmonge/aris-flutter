import 'package:flutter/material.dart';

import '../../../../core/models/event_model.dart';
import '../../../../core/repositories/calendar_repository.dart';
import '../../../../theme/aris_list_palette.dart';
import '../../../../theme/app_spacing.dart';
import 'calendar_week_view.dart';
import 'calendar_event_format.dart';
import 'calendar_week_selected_event_card.dart';
import 'event_detail_sheet.dart';

/// Cuadrícula mensual + lista del día seleccionado (v0.49.45).
class CalendarMonthView extends StatefulWidget {
  const CalendarMonthView({
    super.key,
    required this.calendarRepository,
  });

  final CalendarRepository calendarRepository;

  @override
  State<CalendarMonthView> createState() => _CalendarMonthViewState();
}

class _CalendarMonthViewState extends State<CalendarMonthView> {
  static const _monthNames = <String>[
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  late DateTime _month;
  late int _selectedDay;
  String? _selectedEventId;
  bool _detailExpanded = false;

  String get _monthTitleLabel =>
      '${_monthNames[_month.month - 1]} ${_month.year}';

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _month = DateTime(n.year, n.month);
    _selectedDay = n.day;
  }

  void _shiftMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
      _selectedDay = 1;
      _selectedEventId = null;
      _detailExpanded = false;
    });
  }

  void _openEventEditor(EventModel event) {
    EventDetailSheet.show(context, event);
  }

  @override
  Widget build(BuildContext context) {
    final first = DateTime(_month.year, _month.month);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leading = first.weekday - DateTime.monday;
    final totalCells = ((leading + daysInMonth + 6) ~/ 7) * 7;

    final selectedEvents =
        widget.calendarRepository.getMonthEvents(_month, _selectedDay);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => _shiftMonth(-1),
                icon: Icon(
                  Icons.chevron_left_rounded,
                  color: context.arisList.accent,
                ),
              ),
              Expanded(
                child: Text(
                  _monthTitleLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.arisList.textPrimary,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => _shiftMonth(1),
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: context.arisList.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: CalendarWeekView.weekdayShortLabels
                .map(
                  (l) => Expanded(
                    child: Center(
                      child: Text(
                        l,
                        style: TextStyle(
                          fontSize: 11,
                          color: context.arisList.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.xxs),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1.05,
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
              final isToday = _month.year == DateTime.now().year &&
                  _month.month == DateTime.now().month &&
                  dayNum == DateTime.now().day;

              return InkWell(
                onTap: () => setState(() {
                  _selectedDay = dayNum;
                  _selectedEventId = null;
                  _detailExpanded = false;
                }),
                borderRadius: BorderRadius.circular(8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: selected
                        ? context.arisList.accent.withValues(alpha: 0.16)
                        : isToday
                            ? context.arisList.elevated
                                .withValues(alpha: 0.5)
                            : null,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? context.arisList.borderSelected
                          : context.arisList.borderNormal,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w500,
                          color: selected
                              ? context.arisList.accent
                              : context.arisList.textPrimary,
                        ),
                      ),
                      if (hasDot)
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: context.arisList.accent,
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
            CalendarEventFormat.monthDayHeader(_month, _selectedDay),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.arisList.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (selectedEvents.isEmpty)
            Text(
              'Sin eventos para este día.',
              style: TextStyle(
                fontSize: 14,
                color: context.arisList.textMuted,
              ),
            )
          else
            ...selectedEvents.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: CalendarWeekSelectedEventCard(
                  event: e,
                  isExpanded: _selectedEventId == e.id && _detailExpanded,
                  onToggle: () => setState(() {
                    if (_selectedEventId == e.id && _detailExpanded) {
                      _detailExpanded = false;
                    } else {
                      _selectedEventId = e.id;
                      _detailExpanded = true;
                    }
                  }),
                  onEdit: () => _openEventEditor(e),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
