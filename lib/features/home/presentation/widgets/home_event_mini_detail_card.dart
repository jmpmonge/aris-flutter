import 'package:flutter/material.dart';

import '../../../../core/models/event_model.dart';
import '../../../../theme/aris_list_palette.dart';

/// Mini ficha local del Home — sin tarjeta del Calendario Día (v0.49.91).
class HomeEventMiniDetailCard extends StatelessWidget {
  const HomeEventMiniDetailCard({
    super.key,
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

    if (event.participants.isNotEmpty) {
      final joined = event.participants.join(', ');
      if (!_isDuplicate(joined)) lines.add(joined);
    }

    final mins = event.durationMinutes;
    if (mins != null && mins > 0) {
      final duration = mins < 60
          ? '$mins min'
          : (mins % 60 == 0
              ? (mins ~/ 60 == 1 ? '1 h' : '${mins ~/ 60} h')
              : '${mins ~/ 60} h ${mins % 60} min');
      if (!_isDuplicate(duration)) lines.add(duration);
    }

    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final list = context.arisList;
    final extras = _extraLines();

    return Container(
      margin: const EdgeInsets.only(top: 8),
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
