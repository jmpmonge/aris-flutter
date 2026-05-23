import 'package:flutter/material.dart';

import '../../../../core/models/event_model.dart';
import '../../../calendar/presentation/widgets/calendar_day_event_card.dart';

/// Fila de evento en HOY — hora, punto y [CalendarDayEventCard] del Día (v0.49.88).
class HomeEventTimelineRow extends StatelessWidget {
  const HomeEventTimelineRow({
    super.key,
    required this.event,
    required this.timeLabel,
    required this.isExpanded,
    required this.onToggle,
    required this.onEdit,
    required this.timeColumnWidth,
    required this.timelineColumnWidth,
    required this.timelineTextGap,
    required this.dotSize,
    required this.dotPaddingTop,
    required this.dotColor,
    required this.timeTextColor,
    this.minRowHeight,
  });

  final EventModel event;
  final String timeLabel;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final double timeColumnWidth;
  final double timelineColumnWidth;
  final double timelineTextGap;
  final double dotSize;
  final double dotPaddingTop;
  final Color dotColor;
  final Color timeTextColor;
  final double? minRowHeight;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: timeColumnWidth,
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                timeLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.25,
                  fontWeight: FontWeight.w500,
                  color: timeTextColor,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: timelineColumnWidth,
          child: Padding(
            padding: EdgeInsets.only(top: dotPaddingTop),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: timelineTextGap),
        Expanded(
          child: CalendarDayEventCard(
            key: ValueKey('home-day-card-${event.id}'),
            event: event,
            isExpanded: isExpanded,
            onToggle: onToggle,
            onEdit: onEdit,
          ),
        ),
      ],
    );

    if (minRowHeight != null) {
      return SizedBox(height: minRowHeight, child: row);
    }
    return row;
  }
}
