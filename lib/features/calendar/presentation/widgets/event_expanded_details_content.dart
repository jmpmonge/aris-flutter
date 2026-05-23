import 'package:flutter/material.dart';

import '../../../../core/models/event_model.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/aris_list_palette.dart';
import 'calendar_event_format.dart';
import 'calendar_event_icon.dart';

/// Contenido informativo de evento expandido — icono, título, detalles y Editar (v0.49.92).
class EventExpandedDetailsContent extends StatelessWidget {
  const EventExpandedDetailsContent({
    super.key,
    required this.event,
    required this.onEdit,
    this.showTitleRow = false,
    this.hideLocation = false,
  });

  final EventModel event;
  final VoidCallback onEdit;
  final bool showTitleRow;
  final bool hideLocation;

  @override
  Widget build(BuildContext context) {
    final location =
        hideLocation ? null : CalendarEventFormat.expandedLocation(event);
    final reminder = CalendarEventFormat.expandedReminder(event);
    final observations = CalendarEventFormat.expandedObservations(event);
    final participants = event.participants.isNotEmpty
        ? event.participants.join(', ')
        : null;
    final mins = CalendarEventFormat.durationMinutes(event);
    final duration =
        mins != null && mins > 0 ? CalendarEventFormat.gapDuration(mins) : null;

    final detailLines = <_DetailLine>[
      if (location != null)
        _DetailLine(icon: Icons.place_outlined, text: location),
      if (reminder != null)
        _DetailLine(icon: Icons.notifications_outlined, text: reminder),
      if (observations != null)
        _DetailLine(icon: Icons.notes_outlined, text: observations),
      if (participants != null)
        _DetailLine(icon: Icons.people_outline_rounded, text: participants),
      if (duration != null)
        _DetailLine(icon: Icons.schedule_outlined, text: duration),
    ];

    final hasDetails = detailLines.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTitleRow) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  CalendarEventIconResolver.resolve(event),
                  size: 18,
                  color: context.arisList.accent,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.22,
                    fontWeight: FontWeight.w600,
                    color: context.arisList.textPrimary,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (hasDetails)
            SizedBox(height: AppSpacing.calendarDayExpandedDetailTopGap),
        ],
        if (!showTitleRow && hasDetails)
          SizedBox(height: AppSpacing.calendarDayExpandedDetailTopGap),
        for (var i = 0; i < detailLines.length; i++) ...[
          if (i > 0)
            SizedBox(height: AppSpacing.calendarDayExpandedDetailRowGap),
          EventExpandedIconLine(
            icon: detailLines[i].icon,
            text: detailLines[i].text,
            maxLines: detailLines[i].icon == Icons.notes_outlined ? 6 : 3,
          ),
        ],
        SizedBox(
          height: showTitleRow || hasDetails
              ? AppSpacing.calendarDayExpandedEditTopGap
              : AppSpacing.xxs,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onEdit,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: context.arisList.accent,
            ),
            child: const Text(
              'Editar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailLine {
  const _DetailLine({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

/// Línea con icono pequeño en detalle expandido de evento.
class EventExpandedIconLine extends StatelessWidget {
  const EventExpandedIconLine({
    super.key,
    required this.icon,
    required this.text,
    this.maxLines = 3,
  });

  final IconData icon;
  final String text;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            icon,
            size: 15,
            color: context.arisList.textMuted.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.28,
              fontWeight: FontWeight.w400,
              color: context.arisList.textSecondary,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
