import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Ruleta de hora con acento de sección (v0.49.23).
abstract final class SectionAccentTimeWheelPicker {
  SectionAccentTimeWheelPicker._();

  static Future<TimeOfDay?> show({
    required BuildContext context,
    required Color accent,
    TimeOfDay? initialTime,
  }) {
    return showModalBottomSheet<TimeOfDay>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => _TimeWheelSheet(
        accent: accent,
        initialTime: initialTime ?? TimeOfDay.now(),
      ),
    );
  }
}

class _TimeWheelSheet extends StatefulWidget {
  const _TimeWheelSheet({
    required this.accent,
    required this.initialTime,
  });

  final Color accent;
  final TimeOfDay initialTime;

  @override
  State<_TimeWheelSheet> createState() => _TimeWheelSheetState();
}

class _TimeWheelSheetState extends State<_TimeWheelSheet> {
  late DateTime _pickerDateTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final t = widget.initialTime;
    _pickerDateTime = DateTime(now.year, now.month, now.day, t.hour, t.minute);
  }

  TimeOfDay _toTimeOfDay(DateTime dt) => TimeOfDay(hour: dt.hour, minute: dt.minute);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cupertinoBase = CupertinoTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, _toTimeOfDay(_pickerDateTime)),
                  style: TextButton.styleFrom(foregroundColor: widget.accent),
                  child: const Text('Listo'),
                ),
              ],
            ),
          ),
          CupertinoTheme(
            data: cupertinoBase.copyWith(primaryColor: widget.accent),
            child: SizedBox(
              height: 216,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: _pickerDateTime,
                use24hFormat: true,
                onDateTimeChanged: (dt) => setState(() => _pickerDateTime = dt),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
