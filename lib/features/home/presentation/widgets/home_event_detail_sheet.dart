import 'package:flutter/material.dart';

import '../../../../core/models/event_model.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/aris_list_palette.dart';
import '../../../calendar/presentation/widgets/event_detail_sheet.dart';
import '../../../calendar/presentation/widgets/event_expanded_details_content.dart';

/// Ficha flotante de detalle de evento en Home (v0.49.93).
abstract final class HomeEventDetailSheet {
  HomeEventDetailSheet._();

  static Future<void> show(BuildContext context, EventModel event) {
    final scheme = Theme.of(context).colorScheme;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: context.arisList.cardFill,
      barrierColor: scheme.scrim.withValues(alpha: 0.45),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (ctx) => _HomeEventDetailSheetBody(event: event),
    );
  }
}

class _HomeEventDetailSheetBody extends StatelessWidget {
  const _HomeEventDetailSheetBody({required this.event});

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.md + bottomInset,
      ),
      child: EventExpandedDetailsContent(
        event: event,
        showTitleRow: true,
        onEdit: () async {
          Navigator.of(context).pop();
          await EventDetailSheet.show(context, event);
        },
      ),
    );
  }
}
