import 'package:flutter/material.dart';

import '../../../../core/models/event_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import 'calendar_event_format.dart';
import 'calendar_event_icon.dart';

/// Tarjeta de evento en agenda Día — colapsada o desplegada (v0.49.45).
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
    final category = CalendarEventIconResolver.categoryLabel(event);

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
              horizontal: AppSpacing.sm + 2,
              vertical: 10,
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
                    const SizedBox(width: AppSpacing.sm),
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
                const SizedBox(height: 3),
                Text(
                  timeSimple,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.2,
                    fontWeight: FontWeight.w500,
                    color: AppColors.calendarListAccentSky,
                  ),
                ),
                if (isExpanded && category.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.2,
                      color: AppColors.calendarListTextMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

/// Cuerpo desplegado de evento en agenda Día (v0.49.45).
///
/// No contiene [CalendarDayEventCard] para evitar recursión.
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
    final notes = CalendarEventFormat.notesText(event);
    final location = event.location.trim();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.sm),
        _DayDetailRow(
          label: 'Fecha',
          value: CalendarEventFormat.shortDate(event),
        ),
        _DayDetailRow(
          label: 'Hora',
          value: CalendarEventFormat.timeHm(event.start),
        ),
        if (location.isNotEmpty)
          _DayDetailRow(label: 'Ubicación', value: location),
        if (notes.isNotEmpty)
          _DayDetailRow(label: 'Notas', value: notes, multiline: true),
        const SizedBox(height: AppSpacing.xs),
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

class _DayDetailRow extends StatelessWidget {
  const _DayDetailRow({
    required this.label,
    required this.value,
    this.multiline = false,
  });

  final String label;
  final String value;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 68,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.calendarListTextMuted.withValues(alpha: 0.85),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                height: 1.32,
                color: AppColors.calendarListTextSecondary,
              ),
              maxLines: multiline ? 4 : 2,
              overflow: multiline ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
