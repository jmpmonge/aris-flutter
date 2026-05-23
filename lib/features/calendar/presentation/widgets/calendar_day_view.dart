import 'package:flutter/material.dart';

import '../../../../core/models/event_model.dart';
import '../../../../core/repositories/calendar_repository.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import 'calendar_day_event_card.dart';
import 'calendar_event_format.dart';
import 'calendar_free_gap_divider.dart';
import 'event_detail_sheet.dart';

/// Agenda vertical del día con timeline adaptativa (v0.49.79).
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
            _DayTimelineStack(
              events: events,
              expandedEventId: _expandedDayEventId,
              onToggle: (id) {
                setState(() {
                  _expandedDayEventId = _expandedDayEventId == id ? null : id;
                });
              },
              onEdit: _openEventEditor,
              buildGapBetween: _buildGapBetween,
            ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildGapBetween(EventModel prev, EventModel next) {
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

/// Lista del día con spine vertical por tramos (centro punto → centro punto).
class _DayTimelineStack extends StatefulWidget {
  const _DayTimelineStack({
    required this.events,
    required this.expandedEventId,
    required this.onToggle,
    required this.onEdit,
    required this.buildGapBetween,
  });

  final List<EventModel> events;
  final String? expandedEventId;
  final ValueChanged<String> onToggle;
  final ValueChanged<EventModel> onEdit;
  final Widget Function(EventModel prev, EventModel next) buildGapBetween;

  @override
  State<_DayTimelineStack> createState() => _DayTimelineStackState();
}

class _DayTimelineStackState extends State<_DayTimelineStack> {
  final _stackKey = GlobalKey();
  final List<GlobalKey> _dotKeys = [];
  List<(double top, double height)> _spineSegments = [];
  int _spineUpdateGeneration = 0;

  static const double _timelineColWidth = 16;
  static const double _spineWidth = AppSpacing.calendarDayTimelineSpineWidth;

  @override
  void initState() {
    super.initState();
    _syncDotKeys();
    _scheduleSpineUpdate();
  }

  @override
  void didUpdateWidget(covariant _DayTimelineStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    final keysChanged = oldWidget.events.length != widget.events.length;
    final layoutChanged = oldWidget.expandedEventId != widget.expandedEventId ||
        keysChanged ||
        oldWidget.events.map((e) => e.id).join() !=
            widget.events.map((e) => e.id).join();
    if (keysChanged) _syncDotKeys();
    if (layoutChanged) _scheduleSpineUpdate(trackExpandAnimation: true);
  }

  void _syncDotKeys() {
    while (_dotKeys.length < widget.events.length) {
      _dotKeys.add(GlobalKey());
    }
    while (_dotKeys.length > widget.events.length) {
      _dotKeys.removeLast();
    }
  }

  void _scheduleSpineUpdate({bool trackExpandAnimation = false}) {
    final generation = ++_spineUpdateGeneration;

    void measure() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || generation != _spineUpdateGeneration) return;
        _updateSpineGeometry();
      });
    }

    measure();

    if (!trackExpandAnimation) return;

    // AnimatedSize de tarjeta (~cardExpandSizeMs): remediar spine durante el despliegue.
    final totalMs =
        AppSpacing.cardExpandSizeMs + AppSpacing.calendarDayTimelineSpineAnimationPadMs;
    const stepMs = 16;
    for (var elapsed = stepMs; elapsed <= totalMs; elapsed += stepMs) {
      Future<void>.delayed(Duration(milliseconds: elapsed), () {
        if (!mounted || generation != _spineUpdateGeneration) return;
        measure();
      });
    }
  }

  void _updateSpineGeometry() {
    if (widget.events.length < 2) {
      if (_spineSegments.isNotEmpty) setState(() => _spineSegments = []);
      return;
    }

    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null) return;

    final stackOrigin = stackBox.localToGlobal(Offset.zero);
    final nextSegments = <(double top, double height)>[];

    for (var i = 0; i < widget.events.length - 1; i++) {
      final boxA = _dotKeys[i].currentContext?.findRenderObject() as RenderBox?;
      final boxB =
          _dotKeys[i + 1].currentContext?.findRenderObject() as RenderBox?;
      if (boxA == null || boxB == null) return;

      final centerA = boxA.localToGlobal(
        Offset(boxA.size.width / 2, boxA.size.height / 2),
      );
      final centerB = boxB.localToGlobal(
        Offset(boxB.size.width / 2, boxB.size.height / 2),
      );

      final top = centerA.dy - stackOrigin.dy;
      final height = centerB.dy - centerA.dy;
      if (height > 0.5) {
        nextSegments.add((top, height));
      }
    }

    if (_segmentsEqual(_spineSegments, nextSegments)) return;

    setState(() => _spineSegments = nextSegments);
  }

  bool _segmentsEqual(
    List<(double top, double height)> a,
    List<(double top, double height)> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if ((a[i].$1 - b[i].$1).abs() > 0.5 || (a[i].$2 - b[i].$2).abs() > 0.5) {
        return false;
      }
    }
    return true;
  }

  Widget _buildGapRow(int index) {
    final prev = widget.events[index - 1];
    final next = widget.events[index];
    final prevExpanded = widget.expandedEventId == prev.id;
    final nextExpanded = widget.expandedEventId == next.id;

    if (prevExpanded || nextExpanded) {
      return _TimelineGapRow(
        minHeight: AppSpacing.calendarDayEventRowGap,
        child: const SizedBox.shrink(),
      );
    }

    return widget.buildGapBetween(prev, next);
  }

  @override
  Widget build(BuildContext context) {
    final spineLeft = AppSpacing.calendarTimeColumnWidth +
        _timelineColWidth / 2 -
        _spineWidth / 2;

    return Stack(
      key: _stackKey,
      clipBehavior: Clip.none,
      children: [
        for (final segment in _spineSegments)
          Positioned(
            left: spineLeft,
            top: segment.$1,
            child: IgnorePointer(
              child: Container(
                width: _spineWidth,
                height: segment.$2,
                color: AppColors.calendarListBorderNormal.withValues(
                  alpha: AppSpacing.calendarDayTimelineSpineOpacity,
                ),
              ),
            ),
          ),
        NotificationListener<SizeChangedLayoutNotification>(
          onNotification: (_) {
            _scheduleSpineUpdate();
            return false;
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < widget.events.length; i++) ...[
                if (i > 0) _buildGapRow(i),
                SizeChangedLayoutNotifier(
                  child: _TimelineEventRow(
                    event: widget.events[i],
                    dotKey: _dotKeys[i],
                    isExpanded: widget.expandedEventId == widget.events[i].id,
                    onToggle: () => widget.onToggle(widget.events[i].id),
                    onEdit: () => widget.onEdit(widget.events[i]),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
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
        const SizedBox(width: 16),
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

class _TimelineEventRow extends StatelessWidget {
  const _TimelineEventRow({
    required this.event,
    required this.dotKey,
    required this.isExpanded,
    required this.onToggle,
    required this.onEdit,
  });

  final EventModel event;
  final GlobalKey dotKey;
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
        _TimelineDot(key: dotKey, filled: true),
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
  const _TimelineDot({super.key, required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.calendarDayTimelineDotTop),
        child: Center(
          child: Container(
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
        ),
      ),
    );
  }
}
