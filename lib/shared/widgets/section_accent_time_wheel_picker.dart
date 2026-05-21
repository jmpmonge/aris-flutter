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
  static const double _pickerHeight = 216;
  static const double _selectionBandHeight = 34;

  /// Relleno de la franja activa (v0.49.23 — tinte muy sutil por sección).
  static const double _selectionFillAlpha = 0.07;

  /// Borde/halo mínimo de la franja activa.
  static const double _selectionBorderAlpha = 0.14;

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
              height: _pickerHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: _pickerDateTime,
                    use24hFormat: true,
                    onDateTimeChanged: (dt) =>
                        setState(() => _pickerDateTime = dt),
                  ),
                  IgnorePointer(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.accent.withValues(
                            alpha: _selectionFillAlpha,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: widget.accent.withValues(
                              alpha: _selectionBorderAlpha,
                            ),
                            width: 0.5,
                          ),
                        ),
                        child: const SizedBox(
                          height: _selectionBandHeight,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
