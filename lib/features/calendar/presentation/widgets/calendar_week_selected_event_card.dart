import 'package:flutter/material.dart';

import '../../../../core/models/event_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import 'calendar_event_format.dart';
import 'calendar_event_icon.dart';

/// Tarjeta inferior de detalle del evento seleccionado en Semana (v0.49.70).
class CalendarWeekSelectedEventCard extends StatelessWidget {
  const CalendarWeekSelectedEventCard({
    super.key,
    required this.event,
    this.onOpenDetail,
  });

  final EventModel event;
  final VoidCallback? onOpenDetail;

  static const double _radius = AppSpacing.radiusMd;

  @override
  Widget build(BuildContext context) {
    final icon = CalendarEventIconResolver.resolve(event);
    final subtitle = CalendarEventFormat.weekSelectedCardSubtitle(event);
    final reminder = CalendarEventFormat.expandedReminder(event);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpenDetail,
        borderRadius: BorderRadius.circular(_radius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.calendarListCardFill.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(
              color: AppColors.calendarListBorderSelected.withValues(alpha: 0.75),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm + 2,
              AppSpacing.sm,
              AppSpacing.sm + 2,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    icon,
                    size: 22,
                    color: AppColors.calendarListAccent,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.25,
                          color: AppColors.calendarListTextSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (reminder != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.notifications_outlined,
                              size: 14,
                              color: AppColors.calendarListAccent.withValues(
                                alpha: 0.85,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                reminder,
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.2,
                                  color: AppColors.calendarListTextMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (onOpenDetail != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onOpenDetail,
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.calendarListAccent.withValues(alpha: 0.9),
                    ),
                    tooltip: 'Ver detalle',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
