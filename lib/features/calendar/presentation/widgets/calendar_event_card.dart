import 'package:flutter/material.dart';

import '../../../../core/models/event_model.dart';
import '../../../../theme/aris_list_palette.dart';
import '../../../../theme/app_spacing.dart';
import 'calendar_event_format.dart';
import 'calendar_event_icon.dart';

/// Tarjeta compacta de evento en agenda (v0.49.45).
class CalendarEventCard extends StatelessWidget {
  const CalendarEventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.isSelected = false,
    this.compact = false,
    this.showTimePrefix = false,
    this.agendaDay = false,
  });

  final EventModel event;
  final VoidCallback onTap;
  final bool isSelected;
  final bool compact;
  final bool showTimePrefix;

  /// Vista Día: solo icono, título, hora simple y ubicación.
  final bool agendaDay;

  static const double _radius = 12;

  @override
  Widget build(BuildContext context) {
    final icon = CalendarEventIconResolver.resolve(event);
    final notes = CalendarEventFormat.notesText(event);
    final timeRange = CalendarEventFormat.timeRange(event);
    final timeSimple = CalendarEventFormat.timeHm(event.start);
    final category = CalendarEventIconResolver.categoryLabel(event);
    final location = event.location.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_radius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isSelected
                ? context.arisList.cardExpanded
                : context.arisList.cardFill.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(
              color: isSelected
                  ? context.arisList.borderSelected
                  : context.arisList.borderNormal,
              width: isSelected ? 1.15 : 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? AppSpacing.sm : AppSpacing.sm + 2,
              vertical: compact ? 8 : 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    icon,
                    size: compact ? 16 : 18,
                    color: context.arisList.accent,
                  ),
                ),
                SizedBox(width: compact ? AppSpacing.xs : AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        showTimePrefix
                            ? '${CalendarEventFormat.timeHm(event.start)}  ${event.title}'
                            : event.title,
                        style: TextStyle(
                          fontSize: compact ? 14 : 15,
                          height: 1.22,
                          fontWeight: FontWeight.w600,
                          color: context.arisList.textPrimary,
                        ),
                        maxLines: compact ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (agendaDay) ...[
                        const SizedBox(height: 3),
                        Text(
                          timeSimple,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                            color: context.arisList.accentSky,
                          ),
                        ),
                        if (location.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            location,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.2,
                              color: context.arisList.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ] else ...[
                        if (!compact || timeRange.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            timeRange,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.2,
                              fontWeight: FontWeight.w500,
                              color: context.arisList.accentSky,
                            ),
                          ),
                        ],
                        if (!compact && notes.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            notes,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.32,
                              color: context.arisList.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (!compact && location.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            location,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.2,
                              color: context.arisList.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ] else if (!compact && category.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            category,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.2,
                              color: context.arisList.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
