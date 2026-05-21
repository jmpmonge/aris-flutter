import 'package:flutter/material.dart';

import '../../../core/repositories/repositories.dart';
import '../../../theme/app_spacing.dart';

/// Editor manual de tarea: pantalla completa desde abajo (v0.49.20).
abstract final class ManualTaskEditorPage {
  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: true,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, _, _) => const _ManualTaskEditorScreen(),
        transitionsBuilder: (_, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        },
      ),
    );
  }
}

class _ManualTaskEditorScreen extends StatefulWidget {
  const _ManualTaskEditorScreen();

  @override
  State<_ManualTaskEditorScreen> createState() =>
      _ManualTaskEditorScreenState();
}

class _ManualTaskEditorScreenState extends State<_ManualTaskEditorScreen> {
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

  InputDecoration _borderlessHint(
    String hint,
    TextStyle? hintStyle, {
    String? errorText,
  }) {
    return InputDecoration(
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      hintText: hint,
      hintStyle: hintStyle,
      errorText: errorText,
      contentPadding: EdgeInsets.zero,
      isDense: true,
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
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
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

  Widget _metaControl({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
    String? valueLabel,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accent = active ? scheme.primary : scheme.onSurfaceVariant;
    final alpha = active ? 1.0 : 0.42;

    return InkWell(
      onTap: _busy ? null : onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: accent.withValues(alpha: alpha)),
            if (valueLabel != null && valueLabel.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                valueLabel,
                style: tt.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    final titleStyle = tt.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: scheme.onSurface,
    );
    final bodyStyle = tt.bodyLarge?.copyWith(
      height: 1.45,
      color: scheme.onSurface,
    );
    final titleHint = titleStyle?.copyWith(
      color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
      fontWeight: FontWeight.w600,
    );
    final bodyHint = bodyStyle?.copyWith(
      color: scheme.onSurfaceVariant.withValues(alpha: 0.48),
    );

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Cerrar',
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.md + bottomInset,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _title,
                style: titleStyle,
                enabled: !_busy,
                maxLines: 2,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _bodyFocus.requestFocus(),
                decoration: _borderlessHint(
                  'Título de la tarea',
                  titleHint,
                  errorText: _titleError,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _metaControl(
                    icon: Icons.calendar_today_outlined,
                    active: _date != null,
                    onTap: _pickDate,
                    valueLabel: _date != null ? _dateLabel(_date!) : null,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _metaControl(
                    icon: Icons.schedule_outlined,
                    active: _time != null,
                    onTap: _pickTime,
                    valueLabel: _time != null ? _timeLabel(_time!) : null,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _metaControl(
                    icon: _priorityHigh
                        ? Icons.flag_rounded
                        : Icons.flag_outlined,
                    active: _priorityHigh,
                    onTap: _togglePriority,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Divider(
                height: 1,
                thickness: 1,
                color: scheme.outline.withValues(alpha: 0.16),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: _body,
                  focusNode: _bodyFocus,
                  style: bodyStyle,
                  enabled: !_busy,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  decoration: _borderlessHint('Notas o detalles…', bodyHint),
                ),
              ),
              if (_submitError != null) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    _submitError!,
                    style: tt.bodySmall?.copyWith(color: scheme.error),
                  ),
                ),
              ],
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(_busy ? 'Guardando…' : 'Crear tarea'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
