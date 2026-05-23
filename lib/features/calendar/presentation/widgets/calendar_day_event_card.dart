import 'package:flutter/material.dart';

import '../../../../core/models/event_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import 'calendar_event_format.dart';
import 'calendar_event_icon.dart';

/// Tarjeta de evento en agenda Día — colapsada o desplegada (v0.49.62).
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
    final timeSimple = CalendarEventFormat.timeHm(event.start);

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
                if (!isExpanded) ...[
                  SizedBox(height: AppSpacing.calendarDayEventTitleTimeGap),
                  Text(
                    timeSimple,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                      color: AppColors.calendarListAccentSky,
                    ),
                  ),
                ],
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

/// Cuerpo desplegado compacto de evento en agenda Día (v0.49.62).
class CalendarDayEventExpandedContent extends StatelessWidget {
  const CalendarDayEventExpandedContent({
    super.key,
    required this.event,
    required this.onEdit,
  });

  final EventModel event;
  final VoidCallback onEdit;

  String? _secondaryDetail() {
    final location = event.location.trim();
    if (location.isNotEmpty) return location;
    final notes = CalendarEventFormat.notesText(event);
    if (notes.isNotEmpty) return notes;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final detail = _secondaryDetail();
    final metaStyle = TextStyle(
      fontSize: 12,
      height: 1.25,
      fontWeight: FontWeight.w400,
      color: AppColors.calendarListTextMuted.withValues(alpha: 0.88),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: AppSpacing.calendarDayExpandedMetaTopGap),
        Text(
          CalendarEventFormat.compactDateTimeLine(event),
          style: metaStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (detail != null) ...[
          const SizedBox(height: 3),
          Text(
            detail,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.28,
              fontWeight: FontWeight.w400,
              color: AppColors.calendarListTextSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: AppSpacing.xxs),
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
