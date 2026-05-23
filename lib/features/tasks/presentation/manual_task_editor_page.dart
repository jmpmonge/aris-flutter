import 'package:flutter/material.dart';

import '../../../core/models/task_model.dart';
import '../../../core/repositories/repositories.dart';
import '../../../shared/layout/breakpoints.dart';
import '../../../shared/widgets/editor_compact_meta_field.dart';
import '../../../shared/widgets/manual_editor_time_meta_chip.dart';
import '../../../shared/widgets/section_accent_time_wheel_picker.dart';
import '../../../theme/aris_list_palette.dart';
import '../../../theme/app_spacing.dart';

/// Acento azul Aris para metadatos del editor de tareas (v0.49.44).
abstract final class TaskManualEditorAccent {
  static Color metaActive(BuildContext context) => context.arisList.accent;
}

/// Editor manual de tarea: sheet desde abajo, compacto (v0.49.44).
abstract final class ManualTaskEditorPage {
  static const double _sheetHeightFactor = 0.62;

  static Future<void> show(BuildContext context) {
    return _open(context, const _ManualTaskEditorSheet());
  }

  static Future<void> showEdit(BuildContext context, {required TaskModel task}) {
    return _open(context, _ManualTaskEditorSheet(existing: task));
  }

  static Future<void> _open(BuildContext context, Widget sheet) {
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
      backgroundColor: context.arisList.cardFill,
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
            child: sheet,
          ),
        );
      },
    );
  }
}

class _ManualTaskEditorSheet extends StatefulWidget {
  const _ManualTaskEditorSheet({this.existing});

  final TaskModel? existing;

  bool get isEdit => existing != null;

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
  void initState() {
    super.initState();
    final t = widget.existing;
    if (t == null) return;

    _title.text = t.title;
    _body.text = (t.description ?? '').trim();
    _date = TaskModel.tryParseIsoDateLocal(t.dateIso);
    _time = _parseTime(t.timeText);
    _priorityHigh = (t.priority ?? '').trim().toLowerCase() == 'high';
  }

  TimeOfDay? _parseTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parts = raw.trim().split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

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

  static const double _titleSurfaceVerticalPad = 10;

  Widget _textSurface({
    required Widget child,
    bool titleField = false,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.arisList.elevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: context.arisList.borderNormal.withValues(alpha: 0.55),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical:
              titleField ? _titleSurfaceVerticalPad : AppSpacing.sm + 2,
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
      accent: TaskManualEditorAccent.metaActive(context),
      initialTime: _time,
    );
    if (!mounted || picked == null) return;
    setState(() => _time = picked);
  }

  void _togglePriority() {
    setState(() => _priorityHigh = !_priorityHigh);
  }

  ButtonStyle _primaryButtonStyle() {
    return FilledButton.styleFrom(
      elevation: 0,
      backgroundColor: context.arisList.accent,
      foregroundColor: context.arisList.canvas,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    );
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

    final description =
        _body.text.trim().isEmpty ? null : _body.text.trim();

    bool ok;
    if (widget.isEdit) {
      ok = await Repositories.task.updateTask(
        widget.existing!.id,
        title: t,
        description: description,
      );
    } else {
      ok = await Repositories.task.createTaskOnBackend(
        title: t,
        description: description,
        dateIso: _date != null ? _dateIso(_date!) : null,
        dateText: _date != null ? _dateLabel(_date!) : null,
        timeText: _time != null ? _timeLabel(_time!) : null,
        priority: _priorityHigh ? 'high' : 'normal',
        tags: const <String>[],
      );
    }

    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      setState(
        () => _submitError = widget.isEdit
            ? 'No se pudo guardar la tarea. Inténtalo de nuevo.'
            : 'No se pudo crear la tarea. Inténtalo de nuevo.',
      );
      return;
    }
    Navigator.of(context).pop();
  }

  Widget _metaField({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
    String? valueLabel,
    bool iconOnly = false,
  }) {
    return EditorCompactMetaField(
      icon: icon,
      accent: TaskManualEditorAccent.metaActive(context),
      active: active,
      onTap: onTap,
      valueLabel: valueLabel,
      iconOnly: iconOnly,
      enabled: !_busy,
      surfaceColor: context.arisList.elevated,
      borderColor: context.arisList.borderNormal,
      mutedForeground: context.arisList.textMuted,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final heading = widget.isEdit ? 'Editar tarea' : 'Crear tarea';

    final titleStyle = tt.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      height: 1.2,
      fontSize: 17,
      color: context.arisList.textPrimary,
    );
    final bodyStyle = tt.bodyMedium?.copyWith(
      height: 1.4,
      color: context.arisList.textPrimary,
    );
    final titleHint = titleStyle?.copyWith(
      color: context.arisList.textMuted.withValues(alpha: 0.65),
      fontWeight: FontWeight.w600,
    );
    final bodyHint = bodyStyle?.copyWith(
      color: context.arisList.textMuted.withValues(alpha: 0.55),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.sm,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  heading,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: context.arisList.textPrimary,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.close_rounded,
                  size: 22,
                  color: context.arisList.textMuted,
                ),
                tooltip: 'Cerrar',
                onPressed: _busy ? null : () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _textSurface(
                  titleField: true,
                  child: TextField(
                    controller: _title,
                    style: titleStyle,
                    enabled: !_busy,
                    minLines: 1,
                    maxLines: 1,
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
                    _metaField(
                      icon: Icons.calendar_today_outlined,
                      active: _date != null,
                      onTap: _pickDate,
                      valueLabel: _date != null ? _dateLabel(_date!) : null,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    ManualEditorTimeMetaChip(
                      accent: TaskManualEditorAccent.metaActive(context),
                      active: _time != null,
                      onTap: _pickTime,
                      enabled: !_busy,
                      valueLabel: _time != null ? _timeLabel(_time!) : null,
                      surfaceColor: context.arisList.elevated,
                      borderColor: context.arisList.borderNormal,
                      mutedForeground: context.arisList.textMuted,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _metaField(
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
                    maxLines: 5,
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
                  style: tt.bodySmall?.copyWith(
                    color: context.arisList.destructive,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              FilledButton(
                onPressed: _busy ? null : _submit,
                style: _primaryButtonStyle(),
                child: Text(
                  _busy
                      ? 'Guardando…'
                      : widget.isEdit
                          ? 'Guardar cambios'
                          : 'Crear tarea',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
