import 'package:flutter/material.dart';

import '../../../../core/models/event_model.dart';
import '../../../../core/repositories/calendar_repository.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import 'calendar_day_event_card.dart';
import 'calendar_event_format.dart';
import 'calendar_free_gap_divider.dart';
import 'event_detail_sheet.dart';

/// Agenda vertical del día con línea temporal (v0.49.61).
class CalendarDayView extends StatefulWidget {
  const CalendarDayView({
    super.key,
    required this.calendarRepository,
    this.initialDay,
  });

  final CalendarRepository calendarRepository;
  final DateTime? initialDay;

  @override
  State<CalendarDayView> createState() => _CalendarDayViewState();
}

class _CalendarDayViewState extends State<CalendarDayView> {
  late DateTime _day;
  String? _expandedDayEventId;
  final Map<String, EventModel> _localEventOverrides = {};
  final Set<String> _localDeletedEventIds = {};

  @override
  void initState() {
    super.initState();
    final n = widget.initialDay ?? DateTime.now();
    _day = DateTime(n.year, n.month, n.day);
  }

  void _shiftDay(int delta) {
    setState(() {
      _day = _day.add(Duration(days: delta));
      _expandedDayEventId = null;
    });
  }

  Future<void> _openEventEditor(EventModel event) async {
    final result = await EventDetailSheet.show(context, event);
    if (!mounted || result == null) return;
    setState(() {
      if (result.isDeleted) {
        _localDeletedEventIds.add(result.deletedEventId!);
        _localEventOverrides.remove(event.id);
        if (_expandedDayEventId == event.id) _expandedDayEventId = null;
      } else if (result.event != null) {
        _localEventOverrides[event.id] = result.event!;
      }
    });
  }

  List<EventModel> _dayEvents() {
    return widget.calendarRepository
        .getTodayEvents(_day)
        .where((e) => e.hasCivilCalendarDate)
        .where((e) => !_localDeletedEventIds.contains(e.id))
        .map((e) => _localEventOverrides[e.id] ?? e)
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  @override
  Widget build(BuildContext context) {
    final events = _dayEvents();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DayNavHeader(
            label: CalendarEventFormat.dayHeader(_day),
            onPrev: () => _shiftDay(-1),
            onNext: () => _shiftDay(1),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (events.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(
                'Sin eventos para este día.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.calendarListTextMuted,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            for (var i = 0; i < events.length; i++) ...[
              if (i > 0) _maybeGapRow(events[i - 1], events[i]),
              _TimelineEventRow(
                event: events[i],
                isExpanded: _expandedDayEventId == events[i].id,
                onToggle: () {
                  setState(() {
                    final id = events[i].id;
                    _expandedDayEventId =
                        _expandedDayEventId == id ? null : id;
                  });
                },
                onEdit: () => _openEventEditor(events[i]),
              ),
            ],
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _maybeGapRow(EventModel prev, EventModel next) {
    final gapEnd = prev.end ?? prev.start.add(const Duration(minutes: 30));
    final gapMinutes = next.start.difference(gapEnd).inMinutes;
    if (gapMinutes < 45) {
      return _TimelineGapRow(
        minHeight: AppSpacing.xxs,
        child: const SizedBox.shrink(),
      );
    }
    return _TimelineGapRow(
      minHeight: AppSpacing.calendarDayFreeGapMinHeight,
      child: CalendarFreeGapDivider(durationMinutes: gapMinutes),
    );
  }
}

class _DayNavHeader extends StatelessWidget {
  const _DayNavHeader({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: onPrev,
          icon: Icon(
            Icons.chevron_left_rounded,
            color: AppColors.calendarListAccent,
          ),
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.25,
              fontWeight: FontWeight.w600,
              color: AppColors.calendarListTextPrimary,
            ),
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: onNext,
          icon: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.calendarListAccent,
          ),
        ),
      ],
    );
  }
}

class _TimelineGapRow extends StatelessWidget {
  const _TimelineGapRow({
    required this.minHeight,
    required this.child,
  });

  final double minHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: AppSpacing.calendarTimeColumnWidth),
        _TimelineGapSpine(height: minHeight),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.calendarDayTimelineContentGap,
            ),
            child: SizedBox(
              height: minHeight,
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineGapSpine extends StatelessWidget {
  const _TimelineGapSpine({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: height,
      child: Center(
        child: Container(
          width: 1,
          height: height,
          color: AppColors.calendarListBorderNormal.withValues(alpha: 0.22),
        ),
      ),
    );
  }
}

class _TimelineEventRow extends StatelessWidget {
  const _TimelineEventRow({
    required this.event,
    required this.isExpanded,
    required this.onToggle,
    required this.onEdit,
  });

  final EventModel event;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: AppSpacing.calendarTimeColumnWidth,
          child: Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.calendarDayTimeColumnTop,
            ),
            child: Text(
              CalendarEventFormat.timeHm(event.start),
              style: const TextStyle(
                fontSize: 12,
                height: 1.2,
                fontWeight: FontWeight.w500,
                color: AppColors.calendarListTextSecondary,
              ),
            ),
          ),
        ),
        const _TimelineDot(filled: true),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.calendarDayTimelineContentGap,
            ),
            child: CalendarDayEventCard(
              event: event,
              isExpanded: isExpanded,
              onToggle: onToggle,
              onEdit: onEdit,
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineDot extends StatelessWidget {
  const _TimelineDot({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      child: Column(
        children: [
          SizedBox(height: AppSpacing.calendarDayTimelineDotTop),
          Container(
            width: filled ? 9 : 7,
            height: filled ? 9 : 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled
                  ? AppColors.calendarListTimelineDot
                  : Colors.transparent,
              border: Border.all(
                color: filled
                    ? AppColors.calendarListTimelineDot
                    : AppColors.calendarListEventDotMuted.withValues(alpha: 0.65),
                width: 1.4,
              ),
            ),
          ),
          Container(
            width: 1,
            height: AppSpacing.calendarDayTimelineLineHeight,
            color: AppColors.calendarListBorderNormal.withValues(alpha: 0.9),
          ),
        ],
      ),
    );
  }
}
