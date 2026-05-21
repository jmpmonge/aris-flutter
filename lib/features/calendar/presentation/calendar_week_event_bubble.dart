import 'package:flutter/material.dart';

import '../../../core/models/event_model.dart';
import 'calendar_week_event_badge.dart';

/// Pieza compacta de agenda para la rejilla Semana (v0.49.7).
class CalendarWeekEventBubble extends StatelessWidget {
  const CalendarWeekEventBubble({
    super.key,
    required this.event,
  });

  final EventModel event;

  static const double _minWidthForLabel = 46;
  static const double _iconWellSize = 18;
  static const double _iconSize = 12;
  static const double _accentWidth = 2.5;
  static const double _bubbleRadius = 6;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final badge = CalendarWeekEventBadgeResolver.resolve(event);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final surface = isDark
        ? scheme.surfaceContainerHigh.withValues(alpha: 0.92)
        : scheme.surface;
    final borderColor = scheme.primary.withValues(alpha: isDark ? 0.42 : 0.32);

    return LayoutBuilder(
      builder: (context, constraints) {
        final label = badge.label;
        final showLabel = constraints.maxWidth >= _minWidthForLabel &&
            label.isNotEmpty &&
            label != '·' &&
            label.length <= 8;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(_bubbleRadius),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: isDark ? 0.28 : 0.1),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_bubbleRadius),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ColoredBox(
                  color: scheme.primary.withValues(alpha: 0.85),
                  child: const SizedBox(width: _accentWidth),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 3,
                    ),
                    child: Row(
                      mainAxisAlignment: showLabel
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer.withValues(
                              alpha: isDark ? 0.55 : 0.75,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: scheme.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: SizedBox(
                            width: _iconWellSize,
                            height: _iconWellSize,
                            child: Icon(
                              badge.icon,
                              size: _iconSize,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                        if (showLabel) ...[
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.labelSmall?.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                height: 1,
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
