import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import 'calendar_event_format.dart';

/// Separador compacto de hueco libre en vista Día (v0.49.61, centrado v0.49.80).
///
/// Líneas cortas — duración — líneas cortas, centrado en el hueco visible.
class CalendarFreeGapDivider extends StatelessWidget {
  const CalendarFreeGapDivider({
    super.key,
    required this.durationMinutes,
  });

  final int durationMinutes;

  @override
  Widget build(BuildContext context) {
    final label = CalendarEventFormat.gapDuration(durationMinutes);
    final lineColor = AppColors.calendarListBorderNormal.withValues(
      alpha: AppSpacing.calendarDayFreeGapLineOpacity,
    );
    final textColor = AppColors.calendarListTextMuted.withValues(
      alpha: AppSpacing.calendarDayFreeGapTextOpacity,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: AppSpacing.calendarDayFreeGapLineWidth,
          child: Container(
            height: 1,
            color: lineColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.calendarDayFreeGapTextPaddingH,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              height: 1.15,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.12,
              color: textColor,
            ),
          ),
        ),
        SizedBox(
          width: AppSpacing.calendarDayFreeGapLineWidth,
          child: Container(
            height: 1,
            color: lineColor,
          ),
        ),
      ],
    );
  }
}
