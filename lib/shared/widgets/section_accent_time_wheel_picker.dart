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

  /// Una sola cápsula central (misma geometría Calendario / Tareas).
  static const double _capsuleHeight = 28;
  static const double _capsuleWidth = 128;
  static const double _capsuleRadius = 14;
  static const double _capsuleFillAlpha = 0.09;

  late DateTime _pickerDateTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final t = widget.initialTime;
    _pickerDateTime = DateTime(now.year, now.month, now.day, t.hour, t.minute);
  }

  TimeOfDay _toTimeOfDay(DateTime dt) => TimeOfDay(hour: dt.hour, minute: dt.minute);

  /// Sin overlay nativo por columna: solo la cápsula central del [Stack].
  Widget? _noNativeSelectionOverlay(
    BuildContext context, {
    required int columnCount,
    required int selectedIndex,
  }) {
    return null;
  }

  Widget _selectionCapsule() {
    return IgnorePointer(
      child: Center(
        child: SizedBox(
          width: _capsuleWidth,
          height: _capsuleHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.accent.withValues(alpha: _capsuleFillAlpha),
              borderRadius: BorderRadius.circular(_capsuleRadius),
            ),
          ),
        ),
      ),
    );
  }

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
                  _selectionCapsule(),
                  CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: _pickerDateTime,
                    use24hFormat: true,
                    selectionOverlayBuilder: _noNativeSelectionOverlay,
                    onDateTimeChanged: (dt) =>
                        setState(() => _pickerDateTime = dt),
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
