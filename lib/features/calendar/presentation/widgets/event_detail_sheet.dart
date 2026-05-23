import 'package:flutter/material.dart';

import '../../../../core/models/event_model.dart';
import '../../../../core/repositories/repositories.dart';
import '../../../../shared/widgets/editor_compact_meta_field.dart';
import '../../../../shared/widgets/manual_editor_time_meta_chip.dart';
import '../../../../shared/widgets/section_accent_time_wheel_picker.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../calendar_event_sheet.dart';
import 'calendar_event_format.dart';

void _eventSheetSnack(
  BuildContext context, {
  required String message,
  bool error = false,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger.clearSnackBars();
  final scheme = Theme.of(context).colorScheme;
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: error ? scheme.error : scheme.surfaceContainerHighest,
      content: Text(
        message,
        style: TextStyle(
          color: error ? scheme.onError : scheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}

/// Resultado del sheet de edición de evento (v0.49.66).
class EventDetailSheetResult {
  const EventDetailSheetResult._({this.event, this.deletedEventId});

  const EventDetailSheetResult.saved(EventModel event)
      : this._(event: event);

  const EventDetailSheetResult.deleted(String eventId)
      : this._(deletedEventId: eventId);

  final EventModel? event;
  final String? deletedEventId;

  bool get isDeleted => deletedEventId != null;
}

/// Ficha editable compacta de evento — bottom sheet (v0.49.67).
abstract final class EventDetailSheet {
  EventDetailSheet._();

  static Future<EventDetailSheetResult?> show(
    BuildContext context,
    EventModel event,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return showModalBottomSheet<EventDetailSheetResult>(
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
      builder: (ctx) => _EventEditSheetBody(event: event),
    );
  }
}

class _EventEditSheetBody extends StatefulWidget {
  const _EventEditSheetBody({required this.event});

  final EventModel event;

  @override
  State<_EventEditSheetBody> createState() => _EventEditSheetBodyState();
}

class _EventEditSheetBodyState extends State<_EventEditSheetBody> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _notesCtrl;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  int? _reminderMinutes;
  bool _saving = false;

  static const _monthsShort = <String>[
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  bool get _usesBackend =>
      calendarShouldShowBackendActions(widget.event);

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _titleCtrl = TextEditingController(text: e.title);
    _locationCtrl = TextEditingController(text: e.location.trim());
    _notesCtrl = TextEditingController(text: e.description.trim());
    _selectedDate = DateTime(e.start.year, e.start.month, e.start.day);
    _selectedTime = TimeOfDay(hour: e.start.hour, minute: e.start.minute);
    _reminderMinutes = e.reminderMinutesBefore;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String get _previewTime {
    final h = _selectedTime.hour.toString().padLeft(2, '0');
    final m = _selectedTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _dateLabel(DateTime d) => '${d.day} ${_monthsShort[d.month - 1]}';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now.subtract(const Duration(days: 365 * 2)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await SectionAccentTimeWheelPicker.show(
      context: context,
      accent: AppColors.calendarListAccent,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _pickReminder() async {
    final idx = await showModalBottomSheet<int>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.calendarListCardFill,
      builder: (ctx) {
        final options = CalendarEventFormat.reminderChipOptions;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xs,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Text(
                  'Alarma',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.calendarListTextPrimary,
                  ),
                ),
              ),
              for (var i = 0; i < options.length; i++)
                ListTile(
                  title: Text(
                    options[i].value,
                    style: const TextStyle(
                      color: AppColors.calendarListTextPrimary,
                    ),
                  ),
                  trailing: _reminderMinutes == options[i].key
                      ? Icon(
                          Icons.check_rounded,
                          color: AppColors.calendarListAccent,
                        )
                      : null,
                  onTap: () => Navigator.pop(ctx, i),
                ),
            ],
          ),
        );
      },
    );
    if (!mounted || idx == null) return;
    setState(
      () => _reminderMinutes =
          CalendarEventFormat.reminderChipOptions[idx].key,
    );
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
      accent: AppColors.calendarListAccent,
      active: active,
      onTap: onTap,
      valueLabel: valueLabel,
      iconOnly: iconOnly,
      enabled: !_saving,
      surfaceColor: AppColors.calendarListElevated,
      borderColor: AppColors.calendarListBorderNormal,
      mutedForeground: AppColors.calendarListTextMuted,
    );
  }

  EventModel _buildUpdatedEvent() {
    final e = widget.event;
    final title = _titleCtrl.text.trim();
    final location = _locationCtrl.text.trim();
    final notes = _notesCtrl.text.trim();
    final start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final detailBits = <String>[
      if (location.isNotEmpty) location,
      if (notes.isNotEmpty) notes,
    ];
    return EventModel(
      id: e.id,
      start: start,
      end: e.end,
      title: title.isEmpty ? e.title : title,
      location: location,
      description: notes,
      reminderMinutesBefore: _reminderMinutes,
      detail: detailBits.join(' · '),
      weekIconKey: e.weekIconKey,
      weekLabelText: e.weekLabelText,
      syntheticBackendId: e.syntheticBackendId,
      hasCivilCalendarDate: e.hasCivilCalendarDate,
      dateText: CalendarEventFormat.shortDate(
        EventModel(id: e.id, start: start, title: title),
      ),
      timeText: _previewTime,
      participants: e.participants,
      durationMinutes: e.durationMinutes,
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      _eventSheetSnack(context, message: 'El título no puede estar vacío.', error: true);
      return;
    }

    setState(() => _saving = true);

    if (_usesBackend) {
      final ok = await Repositories.calendar.updateEvent(
        widget.event.id,
        title: title,
        dateText: CalendarEventFormat.shortDate(
          EventModel(
            id: widget.event.id,
            start: _buildUpdatedEvent().start,
            title: title,
          ),
        ),
        timeText: _previewTime,
        location: _locationCtrl.text.trim(),
        description: _notesCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _saving = false);
      if (ok) {
        Navigator.pop(context);
        _eventSheetSnack(context, message: 'Evento actualizado.');
      } else {
        _eventSheetSnack(context, message: 'No he podido actualizar el evento.', error: true);
      }
      return;
    }

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context, EventDetailSheetResult.saved(_buildUpdatedEvent()));
  }

  Future<void> _confirmDelete() async {
    final title = _titleCtrl.text.trim().isEmpty
        ? widget.event.title
        : _titleCtrl.text.trim();
    final scheme = Theme.of(context).colorScheme;
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.calendarListElevated,
        title: const Text(
          '¿Eliminar este evento?',
          style: TextStyle(color: AppColors.calendarListTextPrimary),
        ),
        content: Text(
          'Se eliminará «$title».',
          style: const TextStyle(color: AppColors.calendarListTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (yes != true || !mounted) return;

    if (_usesBackend) {
      Navigator.pop(context);
      await confirmDeleteCalendarBackendEvent(context, widget.event);
      return;
    }

    Navigator.pop(
      context,
      EventDetailSheetResult.deleted(widget.event.id),
    );
  }

  InputDecoration _inlineDecoration(String hint, TextStyle? hintStyle) {
    return InputDecoration(
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      filled: false,
      hintText: hint,
      hintStyle: hintStyle,
      contentPadding: EdgeInsets.zero,
      isDense: true,
      isCollapsed: true,
    );
  }

  Widget _textSurface({required Widget child, bool titleField = false}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.calendarListElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.calendarListBorderNormal.withValues(alpha: 0.55),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: titleField ? 10 : AppSpacing.sm + 2,
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final reminderActive =
        _reminderMinutes != null && _reminderMinutes! > 0;
    final reminderLabel =
        CalendarEventFormat.reminderChipLabel(_reminderMinutes) ?? 'Sin aviso';

    final titleStyle = tt.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      height: 1.2,
      fontSize: 17,
      color: AppColors.calendarListTextPrimary,
    );
    final bodyStyle = tt.bodyMedium?.copyWith(
      height: 1.4,
      color: AppColors.calendarListTextPrimary,
    );
    final titleHint = titleStyle?.copyWith(
      color: AppColors.calendarListTextMuted.withValues(alpha: 0.65),
      fontWeight: FontWeight.w600,
    );
    final bodyHint = bodyStyle?.copyWith(
      color: AppColors.calendarListTextMuted.withValues(alpha: 0.55),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                const Expanded(
                  child: Text(
                    'Editar evento',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.calendarListTextPrimary,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 22,
                    color: AppColors.calendarListTextMuted,
                  ),
                  tooltip: 'Cerrar',
                  onPressed: _saving ? null : () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Flexible(
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
                      controller: _titleCtrl,
                      style: titleStyle,
                      enabled: !_saving,
                      maxLines: 1,
                      decoration: _inlineDecoration(
                        'Título del evento',
                        titleHint,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      _metaField(
                        icon: Icons.calendar_today_outlined,
                        active: true,
                        onTap: _pickDate,
                        valueLabel: _dateLabel(_selectedDate),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      ManualEditorTimeMetaChip(
                        accent: AppColors.calendarListAccent,
                        active: true,
                        onTap: _pickTime,
                        enabled: !_saving,
                        valueLabel: _previewTime,
                        surfaceColor: AppColors.calendarListElevated,
                        borderColor: AppColors.calendarListBorderNormal,
                        mutedForeground: AppColors.calendarListTextMuted,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _metaField(
                        icon: reminderActive
                            ? Icons.notifications_active_outlined
                            : Icons.notifications_outlined,
                        active: reminderActive,
                        onTap: _pickReminder,
                        valueLabel: reminderLabel,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _textSurface(
                    child: TextField(
                      controller: _locationCtrl,
                      style: bodyStyle,
                      enabled: !_saving,
                      maxLines: 1,
                      decoration: _inlineDecoration('Lugar', bodyHint),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _textSurface(
                    child: TextField(
                      controller: _notesCtrl,
                      style: bodyStyle,
                      enabled: !_saving,
                      minLines: 3,
                      maxLines: 5,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      decoration: _inlineDecoration(
                        'Añadir observaciones...',
                        bodyHint,
                      ),
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
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.calendarListAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Guardar cambios',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: _saving ? null : _confirmDelete,
                  style: TextButton.styleFrom(
                    foregroundColor:
                        AppColors.calendarListDestructive.withValues(alpha: 0.9),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Eliminar evento',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
