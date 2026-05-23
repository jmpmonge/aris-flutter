import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import 'calendar_event_format.dart';

/// Separador compacto de hueco libre en vista Día (v0.49.57).
///
/// Sin tarjeta, fondo ni icono — solo línea fina y duración centrada.
class CalendarFreeGapDivider extends StatelessWidget {
  const CalendarFreeGapDivider({
    super.key,
    required this.durationMinutes,
  });

  final int durationMinutes;

  @override
  Widget build(BuildContext context) {
    final label = CalendarEventFormat.gapDuration(durationMinutes);
    final lineColor =
        AppColors.calendarListBorderNormal.withValues(alpha: 0.22);
    final textColor =
        AppColors.calendarListTextMuted.withValues(alpha: 0.42);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.calendarDayFreeGapPaddingV,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(height: 0.5, color: lineColor),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                height: 1.1,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.1,
                color: textColor,
              ),
            ),
          ),
          Expanded(
            child: Container(height: 0.5, color: lineColor),
          ),
        ],
      ),
    );
  }
}
