import 'package:flutter/material.dart';

import '../../../../core/models/event_model.dart';
import '../../../../shared/widgets/premium_pressable.dart';
import '../../../../shared/widgets/smooth_card_expand.dart';
import '../../../../theme/aris_list_palette.dart';
import '../../../../theme/app_spacing.dart';
import 'calendar_event_icon.dart';
import 'event_expanded_details_content.dart';

/// Tarjeta de evento en agenda Día — despliegue instantáneo fiable (v0.49.84).
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

    return PremiumPressable(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(_radius),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: Container(
          decoration: BoxDecoration(
            color: isExpanded
                ? context.arisList.cardExpanded
                : context.arisList.cardFill.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(
              color: isExpanded
                  ? context.arisList.borderSelected
                  : context.arisList.borderNormal,
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
                        maxLines: isExpanded ? 4 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.xs),
                      child: SmoothCardExpandChevron(
                        isExpanded: isExpanded,
                        color: context.arisList.textMuted,
                      ),
                    ),
                  ],
                ),
                SmoothCardExpandReveal(
                  isExpanded: isExpanded,
                  animateSize: false,
                  child: CalendarDayEventExpandedContent(
                    event: event,
                    onEdit: onEdit,
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

/// Cuerpo desplegado mínimo de evento en agenda Día (v0.49.64).
class CalendarDayEventExpandedContent extends StatelessWidget {
  const CalendarDayEventExpandedContent({
    super.key,
    required this.event,
    required this.onEdit,
    this.hideLocation = false,
  });

  final EventModel event;
  final VoidCallback onEdit;
  final bool hideLocation;

  @override
  Widget build(BuildContext context) {
    return EventExpandedDetailsContent(
      event: event,
      onEdit: onEdit,
      hideLocation: hideLocation,
    );
  }
}
