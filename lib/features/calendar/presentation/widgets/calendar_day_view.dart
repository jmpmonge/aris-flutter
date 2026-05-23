import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/models/event_model.dart';
import '../../../../core/repositories/calendar_repository.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import 'calendar_day_event_card.dart';
import 'calendar_event_format.dart';
import 'calendar_free_gap_divider.dart';
import 'event_detail_sheet.dart';

/// Agenda vertical del día — horas ancladas + tarjeta animada aislada (v0.49.81).
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
    });
  }

  Future<void> _openEventEditor(EventModel event) async {
    final result = await EventDetailSheet.show(context, event);
    if (!mounted || result == null) return;
    setState(() {
      if (result.isDeleted) {
        _localDeletedEventIds.add(result.deletedEventId!);
        _localEventOverrides.remove(event.id);
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
              key: ValueKey(_day),
              events: events,
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

/// Lista del día: columna de filas estable + spine en capa aparte.
class _DayTimelineStack extends StatefulWidget {
  const _DayTimelineStack({
    super.key,
    required this.events,
    required this.onEdit,
    required this.buildGapBetween,
  });

  final List<EventModel> events;
  final ValueChanged<EventModel> onEdit;
  final Widget Function(EventModel prev, EventModel next) buildGapBetween;

  @override
  State<_DayTimelineStack> createState() => _DayTimelineStackState();
}

class _DayTimelineStackState extends State<_DayTimelineStack> {
  final _stackKey = GlobalKey();
  final List<GlobalKey> _dotKeys = [];
  final ValueNotifier<int> _spineRemeasureTick = ValueNotifier(0);
  final ValueNotifier<String?> _expandedEventId = ValueNotifier(null);
  final ValueNotifier<bool> _hideTimeLabelsDuringExpand = ValueNotifier(false);
  int _spineAnimationGeneration = 0;
  int _timeHideGeneration = 0;

  static const double _timelineColWidth = 16;

  @override
  void initState() {
    super.initState();
    _syncDotKeys();
    _requestSpineRemeasure();
  }

  @override
  void dispose() {
    _spineRemeasureTick.dispose();
    _expandedEventId.dispose();
    _hideTimeLabelsDuringExpand.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _DayTimelineStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    final keysChanged = oldWidget.events.length != widget.events.length;
    final expandedMissing = _expandedEventId.value != null &&
        !widget.events.any((e) => e.id == _expandedEventId.value);
    if (expandedMissing) {
      _expandedEventId.value = null;
    }
    final layoutChanged = oldWidget.events.map((e) => e.id).join() !=
            widget.events.map((e) => e.id).join() ||
        keysChanged;
    if (keysChanged) _syncDotKeys();
    if (layoutChanged || expandedMissing) {
      _requestSpineRemeasure(trackExpandAnimation: true);
    }
  }

  void _toggleEvent(String id) {
    final next = _expandedEventId.value == id ? null : id;
    if (_expandedEventId.value == next) return;

    _hideTimeLabelsDuringExpand.value = true;
    _expandedEventId.value = next;
    _requestSpineRemeasure(trackExpandAnimation: true);

    final generation = ++_timeHideGeneration;
    final totalMs = AppSpacing.cardExpandSizeMs +
        AppSpacing.calendarDayTimelineSpineAnimationPadMs;
    Future<void>.delayed(Duration(milliseconds: totalMs), () {
      if (!mounted || generation != _timeHideGeneration) return;
      _hideTimeLabelsDuringExpand.value = false;
    });
  }

  void _syncDotKeys() {
    while (_dotKeys.length < widget.events.length) {
      _dotKeys.add(GlobalKey());
    }
    while (_dotKeys.length > widget.events.length) {
      _dotKeys.removeLast();
    }
  }

  void _requestSpineRemeasure({bool trackExpandAnimation = false}) {
    _spineRemeasureTick.value++;

    if (!trackExpandAnimation) return;

    final generation = ++_spineAnimationGeneration;
    final totalMs = AppSpacing.cardExpandSizeMs +
        AppSpacing.calendarDayTimelineSpineAnimationPadMs;
    const stepMs = 16;
    for (var elapsed = stepMs; elapsed <= totalMs; elapsed += stepMs) {
      Future<void>.delayed(Duration(milliseconds: elapsed), () {
        if (!mounted || generation != _spineAnimationGeneration) return;
        _spineRemeasureTick.value++;
      });
    }
  }

  Widget _buildGapRow(int index, String? expandedId) {
    final prev = widget.events[index - 1];
    final next = widget.events[index];
    final prevExpanded = expandedId == prev.id;
    final nextExpanded = expandedId == next.id;

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
        AppSpacing.calendarDayTimelineSpineWidth / 2;

    return Stack(
      key: _stackKey,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: _TimelineSpineLayer(
            stackKey: _stackKey,
            dotKeys: _dotKeys,
            spineLeft: spineLeft,
            remeasureTick: _spineRemeasureTick,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < widget.events.length; i++) ...[
              if (i > 0)
                ListenableBuilder(
                  listenable: _expandedEventId,
                  builder: (context, _) => _buildGapRow(i, _expandedEventId.value),
                ),
              _TimelineEventRow(
                key: ValueKey('day-row-${widget.events[i].id}'),
                event: widget.events[i],
                dotKey: _dotKeys[i],
                expandedListenable: _expandedEventId,
                timeLabelsVisible: _hideTimeLabelsDuringExpand,
                onToggle: () => _toggleEvent(widget.events[i].id),
                onEdit: () => widget.onEdit(widget.events[i]),
                onCardSizeChanged: _requestSpineRemeasure,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Spine en capa propia — setState no reconstruye las filas de hora.
class _TimelineSpineLayer extends StatefulWidget {
  const _TimelineSpineLayer({
    required this.stackKey,
    required this.dotKeys,
    required this.spineLeft,
    required this.remeasureTick,
  });

  final GlobalKey stackKey;
  final List<GlobalKey> dotKeys;
  final double spineLeft;
  final ValueNotifier<int> remeasureTick;

  @override
  State<_TimelineSpineLayer> createState() => _TimelineSpineLayerState();
}

class _TimelineSpineLayerState extends State<_TimelineSpineLayer> {
  List<(double top, double height)> _segments = [];

  @override
  void initState() {
    super.initState();
    widget.remeasureTick.addListener(_scheduleMeasure);
    _scheduleMeasure();
  }

  @override
  void didUpdateWidget(covariant _TimelineSpineLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.remeasureTick != widget.remeasureTick) {
      oldWidget.remeasureTick.removeListener(_scheduleMeasure);
      widget.remeasureTick.addListener(_scheduleMeasure);
    }
    _scheduleMeasure();
  }

  @override
  void dispose() {
    widget.remeasureTick.removeListener(_scheduleMeasure);
    super.dispose();
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _measure();
    });
  }

  void _measure() {
    if (widget.dotKeys.length < 2) {
      if (_segments.isNotEmpty) setState(() => _segments = []);
      return;
    }

    final stackBox =
        widget.stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null) return;

    final stackOrigin = stackBox.localToGlobal(Offset.zero);
    final nextSegments = <(double top, double height)>[];

    for (var i = 0; i < widget.dotKeys.length - 1; i++) {
      final boxA =
          widget.dotKeys[i].currentContext?.findRenderObject() as RenderBox?;
      final boxB =
          widget.dotKeys[i + 1].currentContext?.findRenderObject() as RenderBox?;
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

    if (_segmentsEqual(_segments, nextSegments)) return;
    setState(() => _segments = nextSegments);
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

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final segment in _segments)
            Positioned(
              left: widget.spineLeft,
              top: segment.$1,
              child: Container(
                width: AppSpacing.calendarDayTimelineSpineWidth,
                height: segment.$2,
                color: AppColors.calendarListBorderNormal.withValues(
                  alpha: AppSpacing.calendarDayTimelineSpineOpacity,
                ),
              ),
            ),
        ],
      ),
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
              child: Center(child: child),
            ),
          ),
        ),
      ],
    );
  }
}

/// Hora anclada — oculta durante expand/collapse sin fade (v0.49.83).
class _DayEventTimeLabel extends StatelessWidget {
  const _DayEventTimeLabel({
    super.key,
    required this.label,
    required this.visible,
  });

  final String label;
  final bool visible;

  static const TextStyle _style = TextStyle(
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: AppColors.calendarListTextSecondary,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.calendarTimeColumnWidth,
      child: Padding(
        padding: const EdgeInsets.only(
          top: AppSpacing.calendarDayTimeColumnTop,
        ),
        child: Visibility(
          visible: visible,
          maintainSize: true,
          maintainState: true,
          maintainAnimation: true,
          child: Text(label, style: _style),
        ),
      ),
    );
  }
}

class _TimelineEventRow extends StatelessWidget {
  const _TimelineEventRow({
    super.key,
    required this.event,
    required this.dotKey,
    required this.expandedListenable,
    required this.timeLabelsVisible,
    required this.onToggle,
    required this.onEdit,
    required this.onCardSizeChanged,
  });

  final EventModel event;
  final GlobalKey dotKey;
  final ValueListenable<String?> expandedListenable;
  final ValueListenable<bool> timeLabelsVisible;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onCardSizeChanged;

  @override
  Widget build(BuildContext context) {
    final timeLabel = CalendarEventFormat.timeHm(event.start);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListenableBuilder(
          listenable: timeLabelsVisible,
          builder: (context, _) {
            return _DayEventTimeLabel(
              key: ValueKey('day-time-${event.id}'),
              label: timeLabel,
              visible: !timeLabelsVisible.value,
            );
          },
        ),
        _TimelineDot(key: dotKey, filled: true),
        Expanded(
          child: ListenableBuilder(
            listenable: expandedListenable,
            builder: (context, _) {
              final isExpanded =
                  expandedListenable.value == event.id;
              return Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.calendarDayTimelineContentGap,
                ),
                child: NotificationListener<SizeChangedLayoutNotification>(
                  onNotification: (_) {
                    onCardSizeChanged();
                    return false;
                  },
                  child: SizeChangedLayoutNotifier(
                    child: CalendarDayEventCard(
                      key: ValueKey('day-card-${event.id}'),
                      event: event,
                      isExpanded: isExpanded,
                      onToggle: onToggle,
                      onEdit: onEdit,
                    ),
                  ),
                ),
              );
            },
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
