import 'package:flutter/material.dart';

import '../../core/models/event_model.dart';
import '../../core/models/note_model.dart';
import '../../core/models/task_model.dart';
import '../../theme/app_spacing.dart';

/// Bloque **HOY** — v0.48.2 lista densa (referencia Structured).
class TodaySummaryCard extends StatelessWidget {
  const TodaySummaryCard({
    super.key,
    required this.events,
    required this.tasks,
    this.notes = const [],
  });

  final List<EventModel> events;
  final List<TaskModel> tasks;
  final List<NoteModel> notes;

  static const double _rowSpacing = 10;
  static const double _radius = AppSpacing.homeCardRadius;
  static const double _pad = AppSpacing.homeCardPadding;
  static const double _iconBox = 22;
  static const double _lineFont = 14.5;
  static const double _titleToListGap = 12;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    final titleStyle = theme.textTheme.titleLarge?.copyWith(
          fontSize: 17,
          letterSpacing: 0.2,
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
          height: 1.15,
        ) ??
        TextStyle(
          fontSize: 17,
          letterSpacing: 0.2,
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
          height: 1.15,
        );

    final lineStyle = TextStyle(
      fontSize: _lineFont,
      height: 1.32,
      fontWeight: FontWeight.w400,
      color: scheme.onSurface,
    );

    final items = <(IconData, String)>[];
    for (final e in events) {
      items.add((Icons.schedule_rounded, e.homePreviewLine));
    }
    for (final t in tasks) {
      items.add((Icons.radio_button_unchecked_rounded, t.title));
    }
    for (final n in notes) {
      items.add((Icons.sticky_note_2_outlined, n.homePreviewLine));
    }

    Widget row(int index, IconData icon, String line) {
      final isLast = index == items.length - 1;
      return Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : _rowSpacing),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: _iconBox,
              child: Icon(
                icon,
                size: AppSpacing.homeRowIconSize,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(child: Text(line, style: lineStyle)),
          ],
        ),
      );
    }

    final body = <Widget>[
      Text('HOY', style: titleStyle),
      const SizedBox(height: _titleToListGap),
    ];

    if (items.isEmpty) {
      body.add(
        Text(
          'Nada programado para hoy.',
          style: lineStyle.copyWith(color: scheme.onSurfaceVariant),
        ),
      );
    } else {
      for (var i = 0; i < items.length; i++) {
        final it = items[i];
        body.add(row(i, it.$1, it.$2));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.homePageMarginH),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: isDark ? 0.05 : 0.08),
              blurRadius: AppSpacing.shadowBlurHomeCard,
              offset: AppSpacing.shadowOffsetHomeCard,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(_pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: body,
          ),
        ),
      ),
    );
  }
}
