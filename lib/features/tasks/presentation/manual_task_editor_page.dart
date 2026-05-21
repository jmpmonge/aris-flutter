import 'package:flutter/material.dart';

import '../../../core/repositories/repositories.dart';
import '../../../shared/layout/breakpoints.dart';
import '../../../shared/widgets/section_accent_time_wheel_picker.dart';
import '../../../theme/app_spacing.dart';

/// Naranja solo para metadatos activos en el editor manual (v0.49.20).
abstract final class TaskManualEditorAccent {
  static const Color metaActive = Color(0xFFF4A261);
}

/// Editor manual de tarea: sheet alto desde abajo (~68 %), compacto (v0.49.20).
abstract final class ManualTaskEditorPage {
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
            child: const _ManualTaskEditorSheet(),
          ),
        );
      },
    );
  }
}

class _ManualTaskEditorSheet extends StatefulWidget {
  const _ManualTaskEditorSheet();

  @override
  State<_ManualTaskEditorSheet> createState() => _ManualTaskEditorSheetState();
}

class _ManualTaskEditorSheetState extends State<_ManualTaskEditorSheet> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _bodyFocus = FocusNode();

  DateTime? _date;
  TimeOfDay? _time;
  bool _priorityHigh = false;
  String? _titleError;
  String? _submitError;
  bool _busy = false;

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

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _bodyFocus.dispose();
    super.dispose();
  }

  String? _dateIso(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  String _dateLabel(DateTime d) => '${d.day} ${_monthsShort[d.month - 1]}';

  String _timeLabel(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
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

  Widget _textSurface({
    required Widget child,
  }) {
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
      accent: TaskManualEditorAccent.metaActive,
      initialTime: _time,
    );
    if (!mounted || picked == null) return;
    setState(() => _time = picked);
  }

  void _togglePriority() {
    setState(() => _priorityHigh = !_priorityHigh);
  }

  Future<void> _submit() async {
    final t = _title.text.trim();
    if (t.isEmpty) {
      setState(() => _titleError = 'Escribe un título');
      return;
    }
    if (_busy) return;

    setState(() {
      _titleError = null;
      _submitError = null;
      _busy = true;
    });

    final ok = await Repositories.task.createTaskOnBackend(
      title: t,
      description: _body.text.trim().isEmpty ? null : _body.text.trim(),
      dateIso: _date != null ? _dateIso(_date!) : null,
      dateText: _date != null ? _dateLabel(_date!) : null,
      timeText: _time != null ? _timeLabel(_time!) : null,
      priority: _priorityHigh ? 'high' : 'normal',
      tags: const <String>[],
    );

    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      setState(
        () => _submitError = 'No se pudo crear la tarea. Inténtalo de nuevo.',
      );
      return;
    }
    Navigator.of(context).pop();
  }

  Widget _metaChip({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
    String? valueLabel,
    bool iconOnly = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = active
        ? TaskManualEditorAccent.metaActive
        : scheme.onSurfaceVariant.withValues(alpha: 0.38);
    final iconSize = iconOnly ? 18.0 : 17.0;

    return Material(
      color: active
          ? TaskManualEditorAccent.metaActive.withValues(alpha: 0.14)
          : scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: _busy ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: iconOnly ? 8 : 10,
            vertical: 6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: iconSize, color: color),
              if (!iconOnly && valueLabel != null && valueLabel.isNotEmpty) ...[
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close_rounded, size: 22),
            tooltip: 'Cerrar',
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
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
                    enabled: !_busy,
                    maxLines: 2,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _bodyFocus.requestFocus(),
                    decoration: _fieldDecoration(
                      'Título de la tarea',
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
                      icon: Icons.schedule_outlined,
                      active: _time != null,
                      onTap: _pickTime,
                      valueLabel: _time != null ? _timeLabel(_time!) : null,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _metaChip(
                      icon: _priorityHigh
                          ? Icons.flag_rounded
                          : Icons.flag_outlined,
                      active: _priorityHigh,
                      onTap: _togglePriority,
                      iconOnly: true,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _textSurface(
                  child: TextField(
                    controller: _body,
                    focusNode: _bodyFocus,
                    style: bodyStyle,
                    enabled: !_busy,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_submitError != null) ...[
                Text(
                  _submitError!,
                  style: tt.bodySmall?.copyWith(color: scheme.error),
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              FilledButton(
                onPressed: _busy ? null : _submit,
                style: FilledButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: Text(_busy ? 'Guardando…' : 'Crear tarea'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
