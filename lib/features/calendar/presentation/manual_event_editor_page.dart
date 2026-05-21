import 'package:flutter/material.dart';

import '../../../core/services/local_action_service.dart';
import '../../../shared/layout/breakpoints.dart';
import '../../../shared/widgets/section_accent_time_wheel_picker.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';

/// Azul funcional de Calendario en metadatos activos del editor manual (v0.49.22).
abstract final class EventManualEditorAccent {
  static Color metaActive(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.calendarBlueDark : AppColors.calendarBlue;
  }
}

/// Editor manual de evento: sheet alto alineado con Tareas (v0.49.22).
abstract final class ManualEventEditorPage {
  static const double _sheetHeightFactor = 0.68;

  static Future<void> show(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final sheetConstraints = width > LayoutBreakpoints.webMobileFrameMaxWidth
        ? BoxConstraints(maxWidth: LayoutBreakpoints.webMobileFrameMaxWidth)
        : null;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: scheme.surface,
      barrierColor: scheme.scrim.withValues(alpha: 0.45),
      constraints: sheetConstraints,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (ctx) {
        final viewBottom = MediaQuery.viewInsetsOf(ctx).bottom;
        final sheetH = MediaQuery.sizeOf(ctx).height * _sheetHeightFactor;
        return Padding(
          padding: EdgeInsets.only(bottom: viewBottom),
          child: SizedBox(
            height: sheetH,
            child: const _ManualEventEditorSheet(),
          ),
        );
      },
    );
  }
}

class _ManualEventEditorSheet extends StatefulWidget {
  const _ManualEventEditorSheet();

  @override
  State<_ManualEventEditorSheet> createState() => _ManualEventEditorSheetState();
}

class _ManualEventEditorSheetState extends State<_ManualEventEditorSheet> {
  final _title = TextEditingController();
  final _notes = TextEditingController();
  final _notesFocus = FocusNode();

  DateTime? _date;
  TimeOfDay? _time;
  String _location = '';
  String? _titleError;

  static const _monthsShort = <String>[
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  static const _metaIconSizeDate = 17.0;
  static const _metaIconSizeTime = 15.0;

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  String _dateLabel(DateTime d) => '${d.day} ${_monthsShort[d.month - 1]}';

  String _timeLabel(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String? _whenText() {
    final parts = <String>[];
    if (_date != null) parts.add(_dateLabel(_date!));
    if (_time != null) parts.add(_timeLabel(_time!));
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }

  InputDecoration _fieldDecoration(
    String hint,
    TextStyle? hintStyle, {
    String? errorText,
  }) {
    return InputDecoration(
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      filled: false,
      hintText: hint,
      hintStyle: hintStyle,
      errorText: errorText,
      contentPadding: EdgeInsets.zero,
      isDense: true,
      isCollapsed: true,
    );
  }

  Widget _textSurface({required Widget child}) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        child: child,
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (!mounted || picked == null) return;
    setState(() => _date = DateTime(picked.year, picked.month, picked.day));
  }

  Future<void> _pickTime() async {
    final picked = await SectionAccentTimeWheelPicker.show(
      context: context,
      accent: EventManualEditorAccent.metaActive(context),
      initialTime: _time,
    );
    if (!mounted || picked == null) return;
    setState(() => _time = picked);
  }

  Future<void> _editLocation() async {
    final ctrl = TextEditingController(text: _location);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Ubicación'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Ej. Oficina, Zoom…',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Listo'),
            ),
          ],
        );
      },
    );
    ctrl.dispose();
    if (!mounted || result == null) return;
    setState(() => _location = result);
  }

  void _submit() {
    final t = _title.text.trim();
    if (t.isEmpty) {
      setState(() => _titleError = 'Escribe un título');
      return;
    }

    final noteText = _notes.text.trim();
    final descParts = <String>[];
    if (noteText.isNotEmpty) descParts.add(noteText);
    if (_location.isNotEmpty) descParts.add(_location);

    LocalActionService.createEvent(
      title: t,
      description: descParts.isEmpty ? null : descParts.join('\n'),
      dateText: _whenText(),
    );
    Navigator.of(context).pop();
  }

  Widget _metaChip({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
    String? valueLabel,
    double iconSize = _metaIconSizeDate,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accent = EventManualEditorAccent.metaActive(context);
    final color = active
        ? accent
        : scheme.onSurfaceVariant.withValues(alpha: 0.38);

    return Material(
      color: active
          ? accent.withValues(alpha: 0.14)
          : scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: iconSize, color: color),
              if (valueLabel != null && valueLabel.isNotEmpty) ...[
                const SizedBox(width: 5),
                Text(
                  valueLabel,
                  style: tt.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final titleStyle = tt.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      height: 1.15,
      fontSize: 22,
      color: scheme.onSurface,
    );
    final bodyStyle = tt.bodyMedium?.copyWith(
      height: 1.4,
      color: scheme.onSurface,
    );
    final titleHint = titleStyle?.copyWith(
      color: scheme.onSurfaceVariant.withValues(alpha: 0.45),
      fontWeight: FontWeight.w600,
    );
    final bodyHint = bodyStyle?.copyWith(
      color: scheme.onSurfaceVariant.withValues(alpha: 0.42),
    );

    final locationLabel = _location.isEmpty
        ? null
        : (_location.length > 14 ? '${_location.substring(0, 14)}…' : _location);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close_rounded, size: 22),
            tooltip: 'Cerrar',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _textSurface(
                  child: TextField(
                    controller: _title,
                    style: titleStyle,
                    maxLines: 2,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _notesFocus.requestFocus(),
                    decoration: _fieldDecoration(
                      'Título del evento',
                      titleHint,
                      errorText: _titleError,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    _metaChip(
                      icon: Icons.calendar_today_outlined,
                      active: _date != null,
                      onTap: _pickDate,
                      valueLabel: _date != null ? _dateLabel(_date!) : null,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _metaChip(
                      icon: Icons.access_time_rounded,
                      active: _time != null,
                      onTap: _pickTime,
                      valueLabel: _time != null ? _timeLabel(_time!) : null,
                      iconSize: _metaIconSizeTime,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _metaChip(
                      icon: Icons.place_outlined,
                      active: _location.isNotEmpty,
                      onTap: _editLocation,
                      valueLabel: locationLabel,
                      iconSize: _metaIconSizeDate,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _textSurface(
                  child: TextField(
                    controller: _notes,
                    focusNode: _notesFocus,
                    style: bodyStyle,
                    minLines: 3,
                    maxLines: 6,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    decoration: _fieldDecoration('Notas o detalles…', bodyHint),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: const Text('Crear evento'),
          ),
        ),
      ],
    );
  }
}
