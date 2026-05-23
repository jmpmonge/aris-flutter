import 'package:flutter/material.dart';

import '../../../../core/models/event_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import 'calendar_event_format.dart';
import 'calendar_event_icon.dart';

/// Tarjeta de evento en agenda Día — colapsada o desplegada (v0.49.64).
class CalendarDayEventCard extends StatelessWidget {
  const CalendarDayEventCard({
    super.key,
    required this.event,
    required this.isExpanded,
    required this.onToggle,
    required this.onEdit,
  });

  final EventModel event;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  static const double _radius = 12;

  @override
  Widget build(BuildContext context) {
    final icon = CalendarEventIconResolver.resolve(event);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(_radius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isExpanded
                ? AppColors.calendarListCardExpanded
                : AppColors.calendarListCardFill.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(
              color: isExpanded
                  ? AppColors.calendarListBorderSelected
                  : AppColors.calendarListBorderNormal,
              width: isExpanded ? 1.15 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.calendarDayEventCardPaddingH,
              vertical: AppSpacing.calendarDayEventCardPaddingV,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Icon(
                        icon,
                        size: 18,
                        color: AppColors.calendarListAccent,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.calendarListTextPrimary,
                        ),
                        maxLines: isExpanded ? 4 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.xs),
                        child: Icon(
                          Icons.expand_less_rounded,
                          size: 20,
                          color: AppColors.calendarListTextMuted,
                        ),
                      ),
                  ],
                ),
                if (isExpanded)
                  CalendarDayEventExpandedContent(
                    event: event,
                    onEdit: onEdit,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cuerpo desplegado mínimo de evento en agenda Día (v0.49.64).
class CalendarDayEventExpandedContent extends StatelessWidget {
  const CalendarDayEventExpandedContent({
    super.key,
    required this.event,
    required this.onEdit,
  });

  final EventModel event;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final location = CalendarEventFormat.expandedLocation(event);
    final reminder = CalendarEventFormat.expandedReminder(event);
    final observations = CalendarEventFormat.expandedObservations(event);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (location != null ||
            reminder != null ||
            observations != null) ...[
          SizedBox(height: AppSpacing.calendarDayExpandedDetailTopGap),
          if (location != null)
            _ExpandedIconLine(
              icon: Icons.place_outlined,
              text: location,
            ),
          if (reminder != null) ...[
            if (location != null)
              SizedBox(height: AppSpacing.calendarDayExpandedDetailRowGap),
            _ExpandedIconLine(
              icon: Icons.notifications_outlined,
              text: reminder,
            ),
          ],
          if (observations != null) ...[
            if (location != null || reminder != null)
              SizedBox(height: AppSpacing.calendarDayExpandedDetailRowGap),
            _ExpandedIconLine(
              icon: Icons.notes_outlined,
              text: observations,
            ),
          ],
        ],
        SizedBox(
          height: location != null || reminder != null || observations != null
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
              foregroundColor: AppColors.calendarListAccent,
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

class _ExpandedIconLine extends StatelessWidget {
  const _ExpandedIconLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

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
            color: AppColors.calendarListTextMuted.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.28,
              fontWeight: FontWeight.w400,
              color: AppColors.calendarListTextSecondary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
