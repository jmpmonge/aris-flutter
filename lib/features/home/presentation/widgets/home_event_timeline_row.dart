import 'package:flutter/material.dart';

import '../../../../core/models/event_model.dart';
import '../../../../shared/widgets/premium_pressable.dart';
import '../../../../shared/widgets/smooth_card_expand.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/aris_list_palette.dart';
import '../../../calendar/presentation/widgets/calendar_event_format.dart';

/// Fila compacta HOY + ficha contextual debajo (v0.49.90).
class HomeEventTimelineRow extends StatelessWidget {
  const HomeEventTimelineRow({
    super.key,
    required this.event,
    required this.timeLabel,
    required this.subtitle,
    required this.isExpanded,
    required this.isDark,
    required this.isLastInList,
    required this.onToggle,
    required this.onEdit,
    required this.timeColumnWidth,
    required this.timelineColumnWidth,
    required this.timelineTextGap,
    required this.rowHeight,
    required this.rowGap,
    required this.lineColor,
    required this.lineWidth,
    required this.lineTrim,
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
  final bool isLastInList;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final double timeColumnWidth;
  final double timelineColumnWidth;
  final double timelineTextGap;
  final double rowHeight;
  final double rowGap;
  final Color lineColor;
  final double lineWidth;
  final double lineTrim;
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

  static const double _expandedPanelTopGap = 8;

  @override
  Widget build(BuildContext context) {
    final showLineBelow = !isLastInList;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
          child: Column(
            children: [
              Padding(
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
              if (showLineBelow) SizedBox(height: lineTrim),
              if (showLineBelow)
                Expanded(
                  child: Center(
                    child: Container(
                      width: lineWidth,
                      color: lineColor,
                    ),
                  ),
                ),
              if (showLineBelow)
                SizedBox(
                  height: rowGap,
                  child: Center(
                    child: Container(
                      width: lineWidth,
                      height: rowGap,
                      color: lineColor,
                    ),
                  ),
                )
              else
                const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ),
        SizedBox(width: timelineTextGap),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: rowHeight,
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
              SmoothCardExpandReveal(
                isExpanded: isExpanded,
                animateSize: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: _expandedPanelTopGap),
                  child: _HomeEventExpandedDetail(
                    event: event,
                    compactSubtitle: subtitle,
                    onEdit: onEdit,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Ficha compacta Home — sin repetir lo ya visible en la fila (v0.49.90).
class _HomeEventExpandedDetail extends StatelessWidget {
  const _HomeEventExpandedDetail({
    required this.event,
    required this.compactSubtitle,
    required this.onEdit,
  });

  final EventModel event;
  final String compactSubtitle;
  final VoidCallback onEdit;

  static const double _radius = 12;

  bool _isDuplicate(String? text) {
    if (text == null || text.trim().isEmpty) return true;
    final compact = compactSubtitle.trim();
    if (compact.isEmpty) return false;
    return text.trim() == compact;
  }

  String? _extraLocation() {
    final loc = CalendarEventFormat.expandedLocation(event);
    return _isDuplicate(loc) ? null : loc;
  }

  String? _extraObservations() {
    final obs = CalendarEventFormat.expandedObservations(event);
    return _isDuplicate(obs) ? null : obs;
  }

  String? _extraParticipants() {
    if (event.participants.isEmpty) return null;
    final joined = event.participants.join(', ');
    return _isDuplicate(joined) ? null : joined;
  }

  String? _extraDuration() {
    final mins = CalendarEventFormat.durationMinutes(event);
    if (mins == null || mins <= 0) return null;
    final text = CalendarEventFormat.gapDuration(mins);
    return _isDuplicate(text) ? null : text;
  }

  @override
  Widget build(BuildContext context) {
    final location = _extraLocation();
    final reminder = CalendarEventFormat.expandedReminder(event);
    final observations = _extraObservations();
    final participants = _extraParticipants();
    final duration = _extraDuration();

    final hasDetails = location != null ||
        reminder != null ||
        observations != null ||
        participants != null ||
        duration != null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.arisList.cardExpanded,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(
            color: context.arisList.borderSelected,
            width: 1.15,
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
              if (hasDetails) ...[
                if (location != null)
                  _HomeExpandedIconLine(
                    icon: Icons.place_outlined,
                    text: location,
                  ),
                if (reminder != null) ...[
                  if (location != null)
                    SizedBox(
                      height: AppSpacing.calendarDayExpandedDetailRowGap,
                    ),
                  _HomeExpandedIconLine(
                    icon: Icons.notifications_outlined,
                    text: reminder,
                  ),
                ],
                if (observations != null) ...[
                  if (location != null || reminder != null)
                    SizedBox(
                      height: AppSpacing.calendarDayExpandedDetailRowGap,
                    ),
                  _HomeExpandedIconLine(
                    icon: Icons.notes_outlined,
                    text: observations,
                  ),
                ],
                if (participants != null) ...[
                  if (location != null || reminder != null || observations != null)
                    SizedBox(
                      height: AppSpacing.calendarDayExpandedDetailRowGap,
                    ),
                  _HomeExpandedIconLine(
                    icon: Icons.people_outline_rounded,
                    text: participants,
                  ),
                ],
                if (duration != null) ...[
                  if (location != null ||
                      reminder != null ||
                      observations != null ||
                      participants != null)
                    SizedBox(
                      height: AppSpacing.calendarDayExpandedDetailRowGap,
                    ),
                  _HomeExpandedIconLine(
                    icon: Icons.schedule_outlined,
                    text: duration,
                  ),
                ],
                SizedBox(height: AppSpacing.calendarDayExpandedEditTopGap),
              ] else
                const SizedBox(height: AppSpacing.xxs),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: context.arisList.accent,
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
          ),
        ),
      ),
    );
  }
}

class _HomeExpandedIconLine extends StatelessWidget {
  const _HomeExpandedIconLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            icon,
            size: 15,
            color: context.arisList.textMuted.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.28,
              fontWeight: FontWeight.w400,
              color: context.arisList.textSecondary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
