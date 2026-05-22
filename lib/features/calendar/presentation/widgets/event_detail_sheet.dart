import 'package:flutter/material.dart';

import '../../../../core/models/event_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../calendar_event_sheet.dart';
import 'calendar_event_format.dart';
import 'calendar_event_icon.dart';

/// Ficha de evento — sheet inferior (v0.49.45).
abstract final class EventDetailSheet {
  EventDetailSheet._();

  static Future<void> show(BuildContext context, EventModel event) {
    final scheme = Theme.of(context).colorScheme;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.calendarListCardFill,
      barrierColor: scheme.scrim.withValues(alpha: 0.45),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (ctx) => _EventDetailBody(event: event),
    );
  }
}

class _EventDetailBody extends StatelessWidget {
  const _EventDetailBody({required this.event});

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final icon = CalendarEventIconResolver.resolve(event);
    final category = CalendarEventIconResolver.categoryLabel(event);
    final notes = CalendarEventFormat.notesText(event);
    final canMutate = calendarShouldShowBackendActions(event);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Editar evento',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.calendarListTextPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              if (canMutate)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showCalendarBackendEventEditor(context, event);
                  },
                  child: const Text('Guardar'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.calendarListElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.calendarListBorderNormal),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    icon,
                    size: 28,
                    color: AppColors.calendarListAccent,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.calendarListTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CalendarEventFormat.timeRange(event),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.calendarListAccentSky,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (event.location.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        event.location.trim(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.calendarListTextSecondary,
                        ),
                      ),
                    ],
                    if (category.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.calendarListTextMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _DetailRow(
            label: 'Fecha',
            value: CalendarEventFormat.shortDate(event),
          ),
          _DetailRow(
            label: 'Hora',
            value: CalendarEventFormat.timeRange(event),
          ),
          if (notes.isNotEmpty)
            _DetailRow(label: 'Notas', value: notes, multiline: true),
          if (canMutate) ...[
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                confirmDeleteCalendarBackendEvent(context, event);
              },
              style: TextButton.styleFrom(
                foregroundColor:
                    AppColors.calendarListDestructive.withValues(alpha: 0.85),
              ),
              child: const Text('Eliminar evento'),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
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
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.calendarListElevated.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.calendarListBorderNormal),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 72,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.calendarListTextMuted,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: AppColors.calendarListTextSecondary,
                  ),
                  maxLines: multiline ? 6 : 2,
                  overflow: multiline ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
