import 'package:flutter/material.dart';

import '../../../../core/models/event_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import 'calendar_day_event_card.dart';
import 'calendar_event_format.dart';
import 'calendar_event_icon.dart';

/// Tarjeta inferior de detalle del evento seleccionado en Semana (v0.49.71).
class CalendarWeekSelectedEventCard extends StatelessWidget {
  const CalendarWeekSelectedEventCard({
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

  static const double _radius = AppSpacing.radiusMd;

  @override
  Widget build(BuildContext context) {
    final icon = CalendarEventIconResolver.resolve(event);
    final summaryLine = CalendarEventFormat.weekSelectedCardSubtitle(event);
    final timeLine = CalendarEventFormat.weekCardTimeLine(event);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(_radius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isExpanded
                ? AppColors.calendarListCardExpanded
                : AppColors.calendarListCardFill.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(
              color: isExpanded
                  ? AppColors.calendarListBorderSelected
                  : AppColors.calendarListBorderNormal.withValues(alpha: 0.85),
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
                        size: 20,
                        color: AppColors.calendarListAccent,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
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
                          if (!isExpanded) ...[
                            const SizedBox(height: 3),
                            Text(
                              summaryLine,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.25,
                                color: AppColors.calendarListTextSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 20,
                      color: AppColors.calendarListTextMuted,
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 4),
                  Text(
                    timeLine,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.25,
                      color: AppColors.calendarListTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  CalendarDayEventExpandedContent(
                    event: event,
                    onEdit: onEdit,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
