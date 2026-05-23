import 'package:flutter/material.dart';

import '../../../../core/models/event_model.dart';
import '../../../../core/repositories/repositories.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../calendar_event_sheet.dart';
import 'calendar_event_format.dart';
import 'calendar_event_icon.dart';

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

/// Ficha editable de evento — bottom sheet (v0.49.66).
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
    for (final c in [_titleCtrl, _locationCtrl, _notesCtrl]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String get _previewTitle =>
      _titleCtrl.text.trim().isEmpty ? widget.event.title : _titleCtrl.text.trim();

  String get _previewTime {
    final h = _selectedTime.hour.toString().padLeft(2, '0');
    final m = _selectedTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String? get _previewLocation {
    final loc = _locationCtrl.text.trim();
    return loc.isEmpty ? null : loc;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(_selectedDate.year - 2),
      lastDate: DateTime(_selectedDate.year + 3),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
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
          EventModel(id: widget.event.id, start: _buildUpdatedEvent().start, title: title),
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
          'Se eliminará «$_previewTitle».',
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

  @override
  Widget build(BuildContext context) {
    final icon = CalendarEventIconResolver.resolve(widget.event);
    final dateLabel = CalendarEventFormat.shortDate(
      EventModel(
        id: widget.event.id,
        start: _selectedDate,
        title: _previewTitle,
      ),
    );
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
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
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _PreviewHeader(
              icon: icon,
              title: _previewTitle,
              time: _previewTime,
              location: _previewLocation,
            ),
            const SizedBox(height: AppSpacing.md),
            _EditField(
              label: 'Título',
              controller: _titleCtrl,
            ),
            const SizedBox(height: AppSpacing.sm),
            _EditField(
              label: 'Lugar',
              controller: _locationCtrl,
              hint: 'Añadir lugar...',
            ),
            const SizedBox(height: AppSpacing.sm),
            _EditPickerField(
              label: 'Fecha',
              value: dateLabel,
              onTap: _pickDate,
            ),
            const SizedBox(height: AppSpacing.sm),
            _EditPickerField(
              label: 'Hora',
              value: _previewTime,
              onTap: _pickTime,
            ),
            const SizedBox(height: AppSpacing.sm),
            _ReminderField(
              value: _reminderMinutes,
              onChanged: (v) => setState(() => _reminderMinutes = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            _EditField(
              label: 'Observaciones',
              controller: _notesCtrl,
              hint: 'Añadir observaciones...',
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.calendarListAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
            const SizedBox(height: AppSpacing.xl),
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
    );
  }
}

class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader({
    required this.icon,
    required this.title,
    required this.time,
    this.location,
  });

  final IconData icon;
  final String title;
  final String time;
  final String? location;

  @override
  Widget build(BuildContext context) {
    return Row(
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
            child: Icon(icon, size: 28, color: AppColors.calendarListAccent),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.calendarListTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.calendarListAccentSky,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (location != null) ...[
                const SizedBox(height: 4),
                Text(
                  location!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.calendarListTextSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.calendarListTextPrimary,
      ),
      decoration: _fieldDecoration(label, hint: hint),
    );
  }
}

class _EditPickerField extends StatelessWidget {
  const _EditPickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: _fieldDecoration(label).copyWith(
          suffixIcon: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.calendarListTextMuted,
          ),
        ),
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.calendarListTextPrimary,
          ),
        ),
      ),
    );
  }
}

class _ReminderField extends StatelessWidget {
  const _ReminderField({
    required this.value,
    required this.onChanged,
  });

  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: _fieldDecoration('Aviso'),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          isExpanded: true,
          value: _matchedReminderValue(value),
          dropdownColor: AppColors.calendarListElevated,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.calendarListTextPrimary,
          ),
          items: [
            for (final o in CalendarEventFormat.reminderEditOptions)
              DropdownMenuItem<int?>(
                value: o.key,
                child: Text(o.value),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  int? _matchedReminderValue(int? minutes) {
    for (final o in CalendarEventFormat.reminderEditOptions) {
      if (o.key == minutes) return minutes;
    }
    return null;
  }
}

InputDecoration _fieldDecoration(String label, {String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: AppColors.calendarListElevated,
    labelStyle: const TextStyle(
      color: AppColors.calendarListTextMuted,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: TextStyle(
      color: AppColors.calendarListTextMuted.withValues(alpha: 0.75),
      fontSize: 14,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.calendarListBorderNormal),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.calendarListBorderSelected),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );
}
