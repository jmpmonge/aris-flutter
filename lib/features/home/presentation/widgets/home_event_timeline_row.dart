import 'package:flutter/material.dart';

import '../../../../core/models/event_model.dart';
import '../../../../shared/widgets/premium_pressable.dart';
import '../../../../shared/widgets/smooth_card_expand.dart';
import '../../../../theme/aris_list_palette.dart';
import '../../../calendar/presentation/widgets/calendar_event_format.dart';

/// Fila compacta HOY + mini ficha debajo al expandir (v0.49.91).
class HomeEventTimelineRow extends StatelessWidget {
  const HomeEventTimelineRow({
    super.key,
    required this.event,
    required this.timeLabel,
    required this.subtitle,
    required this.isExpanded,
    required this.isDark,
    required this.onToggle,
    required this.onEdit,
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
  final bool isExpanded;
  final bool isDark;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
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

  static const double _expandedPanelTopGap = 4;

  @override
  Widget build(BuildContext context) {
    final contentInset = timeColumnWidth + timelineColumnWidth + timelineTextGap;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
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
                    onTap: onToggle,
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
        ),
        Padding(
          padding: EdgeInsets.only(left: contentInset),
          child: SmoothCardExpandReveal(
            isExpanded: isExpanded,
            animateSize: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: _expandedPanelTopGap),
                _HomeEventExpandedDetail(
                  event: event,
                  compactSubtitle: subtitle,
                  onEdit: onEdit,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Mini ficha Home — sin repetir datos de la fila compacta (v0.49.91).
class _HomeEventExpandedDetail extends StatelessWidget {
  const _HomeEventExpandedDetail({
    required this.event,
    required this.compactSubtitle,
    required this.onEdit,
  });

  final EventModel event;
  final String compactSubtitle;
  final VoidCallback onEdit;

  static const double _radius = 14;

  bool _isDuplicate(String? text) {
    if (text == null || text.trim().isEmpty) return true;
    final compact = compactSubtitle.trim();
    if (compact.isEmpty) return false;
    return text.trim() == compact;
  }

  List<String> _extraLines() {
    final lines = <String>[];

    final description = event.description.trim();
    if (description.isNotEmpty && !_isDuplicate(description)) {
      lines.add(description);
    }

    final location = event.location.trim();
    if (location.isNotEmpty && !_isDuplicate(location)) {
      lines.add(location);
    }

    if (event.participants.isNotEmpty) {
      final joined = event.participants.join(', ');
      if (!_isDuplicate(joined)) lines.add(joined);
    }

    final reminder = CalendarEventFormat.expandedReminder(event);
    if (reminder != null && !_isDuplicate(reminder)) {
      lines.add(reminder);
    }

    final mins = CalendarEventFormat.durationMinutes(event);
    if (mins != null && mins > 0) {
      final duration = CalendarEventFormat.gapDuration(mins);
      if (!_isDuplicate(duration)) lines.add(duration);
    }

    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final list = context.arisList;
    final extras = _extraLines();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        color: list.elevated,
        border: Border.all(color: list.borderNormal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < extras.length; i++) ...[
            if (i > 0) const SizedBox(height: 4),
            Text(
              extras[i],
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.28,
                fontWeight: FontWeight.w400,
                color: list.textSecondary,
              ),
            ),
          ],
          if (extras.isNotEmpty) const SizedBox(height: 6),
          TextButton(
            onPressed: onEdit,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: list.accent,
            ),
            child: const Text(
              'Editar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
