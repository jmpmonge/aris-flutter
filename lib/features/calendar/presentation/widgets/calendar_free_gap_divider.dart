import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import 'calendar_event_format.dart';

/// Separador compacto de hueco libre en vista Día (v0.49.60).
///
/// Solo contenido (línea — duración — línea). El padding vertical lo define
/// el contenedor en [CalendarDayView].
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Container(
              height: 0.5,
              color: lineColor,
            ),
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
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Container(
              height: 0.5,
              color: lineColor,
            ),
          ),
        ),
      ],
    );
  }
}
