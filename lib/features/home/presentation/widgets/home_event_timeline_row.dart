import 'package:flutter/material.dart';

import '../../../../core/models/event_model.dart';
import '../../../../shared/widgets/premium_pressable.dart';

/// Fila compacta de evento en HOY — sin despliegue inline (v0.49.93).
class HomeEventTimelineRow extends StatelessWidget {
  const HomeEventTimelineRow({
    super.key,
    required this.event,
    required this.timeLabel,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
    required this.timeColumnWidth,
    required this.timelineColumnWidth,
    required this.timelineTextGap,
    required this.rowHeight,
    required this.dotSize,
    required this.dotPaddingTop,
    required this.dotColor,
    required this.timeTextColor,
    required this.titleTextColor,
    required this.subtitleTextColor,
    required this.textPaddingH,
    required this.textPaddingV,
    required this.textBorderRadius,
    required this.textTopOffset,
  });

  final EventModel event;
  final String timeLabel;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;
  final double timeColumnWidth;
  final double timelineColumnWidth;
  final double timelineTextGap;
  final double rowHeight;
  final double dotSize;
  final double dotPaddingTop;
  final Color dotColor;
  final Color timeTextColor;
  final Color titleTextColor;
  final Color subtitleTextColor;
  final double textPaddingH;
  final double textPaddingV;
  final double textBorderRadius;
  final double textTopOffset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: rowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: timeColumnWidth,
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  timeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                    color: timeTextColor,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: timelineColumnWidth,
            child: Padding(
              padding: EdgeInsets.only(top: dotPaddingTop),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: timelineTextGap),
          Expanded(
            child: Transform.translate(
              offset: Offset(0, textTopOffset),
              child: PremiumPressable(
                onTap: onTap,
                borderRadius: BorderRadius.circular(textBorderRadius),
                pressTint: PremiumPressTints.neutral(isDark),
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: 0,
                    end: textPaddingH,
                    top: textPaddingV,
                    bottom: textPaddingV,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.75,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                          color: titleTextColor,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.22,
                            fontWeight: FontWeight.w400,
                            color: subtitleTextColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Subtítulo compacto del evento en HOY (misma lógica que antes de v0.49.88).
String homeEventCompactSubtitle(EventModel event) {
  if (event.detail.trim().isNotEmpty) return event.detail.trim();
  if (event.description.trim().isNotEmpty) return event.description.trim();
  if (event.location.trim().isNotEmpty) return event.location.trim();
  return '';
}
