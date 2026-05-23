import 'package:flutter/material.dart';

import '../../../../core/models/event_model.dart';
import '../../../../core/repositories/calendar_repository.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../calendar_body_views.dart' show calendarSameLocalDay, mondayOfWeek;
import '../calendar_week_event_bubble.dart';
import 'calendar_event_format.dart';
import 'calendar_week_selected_event_card.dart';
import 'event_detail_sheet.dart';

/// Rejilla horaria semanal compacta (v0.49.70).
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
  bool _detailExpanded = false;

  static const int _dayCount = 7;
  static const int _firstHour = 7;
  static const int _lastHour = 21;

  static Color get _gridLineColor => AppColors.calendarListBorderNormal.withValues(
        alpha: AppSpacing.calendarWeekGridLineOpacity,
      );

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
      _detailExpanded = false;
    });
  }

  static EventModel? _eventStartingAtHour(List<EventModel> dayEvents, int hour) {
    for (final e in dayEvents) {
      if (!e.hasCivilCalendarDate) continue;
      if (e.start.hour == hour) return e;
    }
    return null;
  }

  ({EventModel? event, int? dayIndex}) _resolveSelection(
    List<List<EventModel>> eventsByDay,
  ) {
    if (_selectedEventId != null && _selectedDayIndex != null) {
      final idx = _selectedDayIndex!;
      if (idx >= 0 && idx < _dayCount) {
        for (final e in eventsByDay[idx]) {
          if (e.id == _selectedEventId) {
            return (event: e, dayIndex: idx);
          }
        }
      }
    }

    for (var i = 0; i < _dayCount; i++) {
      final sorted = [...eventsByDay[i]]
        ..sort((a, b) => a.start.compareTo(b.start));
      for (final e in sorted) {
        if (e.hasCivilCalendarDate) {
          return (event: e, dayIndex: i);
        }
      }
    }
    return (event: null, dayIndex: null);
  }

  void _onWeekEventTap(EventModel event, int dayIndex) {
    setState(() {
      _selectedEventId = event.id;
      _selectedDayIndex = dayIndex;
      _detailExpanded = false;
    });
  }

  void _openEventEditor(EventModel event) {
    EventDetailSheet.show(context, event);
  }

  Widget _weekDayHeader({
    required int dayIndex,
    required DateTime day,
    required bool isToday,
    required bool isSelected,
  }) {
    final highlight = isSelected || isToday;
    final dayNumberColor = highlight
        ? AppColors.calendarListCanvas
        : AppColors.calendarListTextPrimary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          CalendarWeekView.weekdayShortLabels[dayIndex],
          style: TextStyle(
            fontSize: AppSpacing.calendarWeekDayLetterSize,
            fontWeight: FontWeight.w600,
            height: 1.1,
            color: AppColors.calendarListTextMuted.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 3),
        DecoratedBox(
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.calendarListAccent
                : isToday
                    ? AppColors.calendarListAccent.withValues(alpha: 0.16)
                    : Colors.transparent,
            shape: BoxShape.circle,
            border: isToday && !isSelected
                ? Border.all(
                    color: AppColors.calendarListAccent.withValues(alpha: 0.45),
                  )
                : null,
          ),
          child: SizedBox(
            width: AppSpacing.calendarWeekDayCircleSize,
            height: AppSpacing.calendarWeekDayCircleSize,
            child: Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: AppSpacing.calendarWeekDayNumberSize,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: isSelected
                      ? dayNumberColor
                      : isToday
                          ? AppColors.calendarListAccent
                          : AppColors.calendarListTextPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _weekEventBlock(
    EventModel event,
    int dayIndex, {
    required EventModel? selectedEvent,
    required int? selectedDayIndex,
  }) {
    final isSelected =
        selectedEvent?.id == event.id && selectedDayIndex == dayIndex;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onWeekEventTap(event, dayIndex),
        borderRadius: BorderRadius.circular(6),
        child: CalendarWeekEventBubble(
          event: event,
          isSelected: isSelected,
          iconOnly: true,
        ),
      ),
    );
  }

  Widget _weekHourSlot({
    required int hour,
    required List<EventModel> dayEvents,
    required int dayIndex,
    required bool isLastHour,
    required EventModel? selectedEvent,
    required int? selectedDayIndex,
  }) {
    final match = _eventStartingAtHour(dayEvents, hour);
    return SizedBox(
      height: AppSpacing.calendarWeekSlotHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: _gridLineColor),
            bottom: isLastHour ? BorderSide.none : BorderSide(color: _gridLineColor),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 3, top: 2, right: 2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: match == null
                ? null
                : _weekEventBlock(
                    match,
                    dayIndex,
                    selectedEvent: selectedEvent,
                    selectedDayIndex: selectedDayIndex,
                  ),
          ),
        ),
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
    final selection = _resolveSelection(eventsByDay);
    final selectedDayIndex = selection.dayIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  CalendarEventFormat.monthYearTitle(_weekStart),
                  style: const TextStyle(
                    fontSize: AppSpacing.calendarWeekHeaderTitleSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: AppColors.calendarListTextPrimary,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: () => _shiftWeek(-1),
                icon: Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.calendarListAccent,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: () => _shiftWeek(1),
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.calendarListAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: AppSpacing.calendarTimeColumnWidth),
              for (var i = 0; i < _dayCount; i++)
                Expanded(
                  child: _weekDayHeader(
                    dayIndex: i,
                    day: _weekStart.add(Duration(days: i)),
                    isToday: calendarSameLocalDay(
                      _weekStart.add(Duration(days: i)),
                      now,
                    ),
                    isSelected: selectedDayIndex == i,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (int h = _firstHour; h <= _lastHour; h++)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: AppSpacing.calendarTimeColumnWidth,
                  height: AppSpacing.calendarWeekSlotHeight,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 1, right: 6),
                      child: Text(
                        '${h.toString().padLeft(2, '0')}:00',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.calendarListTextMuted.withValues(
                            alpha: AppSpacing.calendarWeekHourLabelOpacity,
                          ),
                          height: 1.1,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ),
                for (var i = 0; i < _dayCount; i++)
                  Expanded(
                    child: _weekHourSlot(
                      hour: h,
                      dayEvents: eventsByDay[i],
                      dayIndex: i,
                      isLastHour: h == _lastHour,
                      selectedEvent: selection.event,
                      selectedDayIndex: selection.dayIndex,
                    ),
                  ),
              ],
            ),
          if (selection.event != null) ...[
            SizedBox(height: AppSpacing.calendarWeekSelectedCardTopGap),
            CalendarWeekSelectedEventCard(
              event: selection.event!,
              isExpanded: _detailExpanded,
              onExpand: () => setState(() => _detailExpanded = true),
              onEdit: () => _openEventEditor(selection.event!),
            ),
            SizedBox(height: AppSpacing.calendarWeekBottomClearanceExtra),
          ],
        ],
      ),
    );
  }
}
