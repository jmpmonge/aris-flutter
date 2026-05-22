import 'package:flutter/material.dart';

import '../../../../core/models/event_model.dart';
import '../../../../core/repositories/calendar_repository.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../calendar_body_views.dart' show calendarSameLocalDay, mondayOfWeek;
import '../calendar_week_event_bubble.dart';
import 'event_detail_sheet.dart';

/// Rejilla horaria semanal compacta (v0.49.45).
class CalendarWeekView extends StatefulWidget {
  const CalendarWeekView({
    super.key,
    required this.calendarRepository,
    this.initialWeekStart,
  });

  final CalendarRepository calendarRepository;
  final DateTime? initialWeekStart;

  static const weekdayShortLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  State<CalendarWeekView> createState() => _CalendarWeekViewState();
}

class _CalendarWeekViewState extends State<CalendarWeekView> {
  late DateTime _weekStart;
  String? _selectedEventId;
  int? _selectedDayIndex;

  static const int _dayCount = 7;
  static const int _firstHour = 7;
  static const int _lastHour = 21;
  static const double _kWeekSlotHeight = 32;

  @override
  void initState() {
    super.initState();
    _weekStart = widget.initialWeekStart ?? mondayOfWeek(DateTime.now());
  }

  void _shiftWeek(int delta) {
    setState(() {
      _weekStart = _weekStart.add(Duration(days: 7 * delta));
      _selectedEventId = null;
      _selectedDayIndex = null;
    });
  }

  static EventModel? _eventStartingAtHour(List<EventModel> dayEvents, int hour) {
    for (final e in dayEvents) {
      if (!e.hasCivilCalendarDate) continue;
      if (e.start.hour == hour) return e;
    }
    return null;
  }

  void _onWeekEventTap(EventModel event, int dayIndex) {
    setState(() {
      _selectedEventId = event.id;
      _selectedDayIndex = dayIndex;
    });
    EventDetailSheet.show(context, event);
  }

  Widget _weekDayHeader({
    required int dayIndex,
    required DateTime day,
    required bool isToday,
    required bool isSelected,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.calendarListAccent.withValues(alpha: 0.18)
            : isToday
                ? AppColors.calendarListElevated
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? AppColors.calendarListBorderSelected
              : AppColors.calendarListBorderNormal,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Text(
              CalendarWeekView.weekdayShortLabels[dayIndex],
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.calendarListTextMuted,
              ),
            ),
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.1,
                color: isSelected || isToday
                    ? AppColors.calendarListAccent
                    : AppColors.calendarListTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weekEventBlock(BuildContext context, EventModel event, int dayIndex) {
    final isSelected =
        _selectedEventId == event.id && _selectedDayIndex == dayIndex;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onWeekEventTap(event, dayIndex),
        borderRadius: BorderRadius.circular(6),
        child: CalendarWeekEventBubble(
          event: event,
          isSelected: isSelected,
        ),
      ),
    );
  }

  Widget _weekHourSlot({
    required int hour,
    required List<EventModel> dayEvents,
    required int dayIndex,
  }) {
    final match = _eventStartingAtHour(dayEvents, hour);
    return SizedBox(
      height: _kWeekSlotHeight,
      child: Container(
        padding: const EdgeInsets.only(left: 2),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: AppColors.calendarListBorderNormal.withValues(alpha: 0.85),
            ),
          ),
        ),
        alignment: Alignment.centerLeft,
        child: match == null
            ? null
            : _weekEventBlock(context, match, dayIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final eventsByDay = List.generate(_dayCount, (i) {
      final d = _weekStart.add(Duration(days: i));
      return widget.calendarRepository.getWeekEvents(d);
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => _shiftWeek(-1),
                icon: Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.calendarListAccent,
                ),
              ),
              Expanded(
                child: Text(
                  'Semana del ${_weekStart.day}/${_weekStart.month}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.calendarListTextPrimary,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => _shiftWeek(1),
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.calendarListAccent,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: AppSpacing.calendarTimeColumnWidth),
              for (var i = 0; i < _dayCount; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 2 : 1),
                    child: _weekDayHeader(
                      dayIndex: i,
                      day: _weekStart.add(Duration(days: i)),
                      isToday: calendarSameLocalDay(
                        _weekStart.add(Duration(days: i)),
                        now,
                      ),
                      isSelected: _selectedDayIndex == i,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (int h = _firstHour; h <= _lastHour; h++)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: AppSpacing.calendarTimeColumnWidth,
                    child: Text(
                      '${h.toString().padLeft(2, '0')}:00',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.calendarListTextMuted,
                        height: 1.2,
                      ),
                    ),
                  ),
                  for (var i = 0; i < _dayCount; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: i == 0 ? 2 : 1),
                        child: _weekHourSlot(
                          hour: h,
                          dayEvents: eventsByDay[i],
                          dayIndex: i,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
