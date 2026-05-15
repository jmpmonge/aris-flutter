import 'package:flutter/material.dart';

import '../../core/models/local_action_model.dart';
import '../../core/services/local_action_service.dart';
import '../../theme/app_spacing.dart';
import 'app_form_button.dart';
import 'app_text_field.dart';
import 'form_section_title.dart';

/// Formularios modales (bottom sheet) para crear acciones locales sin backend.
abstract final class LocalActionFormSheet {
  static Future<void> showTaskForm(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (ctx) => const _TaskFormBody(),
    );
  }

  static Future<void> showNoteForm(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (ctx) => const _NoteFormBody(),
    );
  }

  static Future<void> showEventForm(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (ctx) => const _EventFormBody(),
    );
  }

  static Future<void> showMailForm(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (ctx) => const _MailFormBody(),
    );
  }

  static EdgeInsets _paddingFor(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.md,
      AppSpacing.lg,
      AppSpacing.lg + bottom,
    );
  }

  static Widget _sheetTitle(BuildContext context, String text) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        text,
        style: theme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _TaskFormBody extends StatefulWidget {
  const _TaskFormBody();

  @override
  State<_TaskFormBody> createState() => _TaskFormBodyState();
}

class _TaskFormBodyState extends State<_TaskFormBody> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  LocalTaskPriority _priority = LocalTaskPriority.medium;
  String? _titleError;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  void _submit() {
    final t = _title.text.trim();
    if (t.isEmpty) {
      setState(() => _titleError = 'Añade un título');
      return;
    }
    setState(() => _titleError = null);
    LocalActionService.createTask(
      title: t,
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      priority: _priority,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: LocalActionFormSheet._paddingFor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LocalActionFormSheet._sheetTitle(context, 'Nueva tarea'),
          const FormSectionTitle('Título'),
          AppTextField(
            controller: _title,
            hint: 'Ej. Llamar al cliente',
            errorText: _titleError,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          const FormSectionTitle('Descripción (opcional)'),
          AppTextField(
            controller: _description,
            maxLines: 3,
            hint: 'Detalles breves',
          ),
          const SizedBox(height: AppSpacing.md),
          const FormSectionTitle('Prioridad'),
          SegmentedButton<LocalTaskPriority>(
            segments: [
              ButtonSegment(
                value: LocalTaskPriority.low,
                label: Text(LocalTaskPriority.low.displayLabel),
              ),
              ButtonSegment(
                value: LocalTaskPriority.medium,
                label: Text(LocalTaskPriority.medium.displayLabel),
              ),
              ButtonSegment(
                value: LocalTaskPriority.high,
                label: Text(LocalTaskPriority.high.displayLabel),
              ),
            ],
            selected: {_priority},
            onSelectionChanged: (s) =>
                setState(() => _priority = s.first),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppFormButton(label: 'Crear tarea', onPressed: _submit),
          const SizedBox(height: AppSpacing.sm),
          AppFormButton(
            label: 'Cancelar',
            primary: false,
            onPressed: () => Navigator.of(context).pop(),
          ),
          SizedBox(height: scheme.brightness == Brightness.dark ? 8 : 0),
        ],
      ),
    );
  }
}

class _NoteFormBody extends StatefulWidget {
  const _NoteFormBody();

  @override
  State<_NoteFormBody> createState() => _NoteFormBodyState();
}

class _NoteFormBodyState extends State<_NoteFormBody> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  String? _category;
  String? _titleError;

  static const _categories = ['Trabajo', 'Personal', 'Ideas'];

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  void _submit() {
    final t = _title.text.trim();
    if (t.isEmpty) {
      setState(() => _titleError = 'Añade un título');
      return;
    }
    setState(() => _titleError = null);
    LocalActionService.createNote(
      title: t,
      content: _content.text,
      category: _category,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: LocalActionFormSheet._paddingFor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LocalActionFormSheet._sheetTitle(context, 'Nueva nota'),
          const FormSectionTitle('Título'),
          AppTextField(
            controller: _title,
            hint: 'Título de la nota',
            errorText: _titleError,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          const FormSectionTitle('Contenido'),
          AppTextField(
            controller: _content,
            maxLines: 4,
            hint: 'Escribe aquí…',
          ),
          const SizedBox(height: AppSpacing.md),
          const FormSectionTitle('Categoría (opcional)'),
          DropdownButtonFormField<String?>(
            initialValue: _category,
            decoration: const InputDecoration(
              hintText: 'Selecciona…',
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Sin categoría'),
              ),
              ..._categories.map(
                (c) => DropdownMenuItem<String?>(
                  value: c,
                  child: Text(c),
                ),
              ),
            ],
            onChanged: (v) => setState(() => _category = v),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppFormButton(label: 'Crear nota', onPressed: _submit),
          const SizedBox(height: AppSpacing.sm),
          AppFormButton(
            label: 'Cancelar',
            primary: false,
            onPressed: () => Navigator.of(context).pop(),
          ),
          SizedBox(height: scheme.brightness == Brightness.dark ? 8 : 0),
        ],
      ),
    );
  }
}

class _EventFormBody extends StatefulWidget {
  const _EventFormBody();

  @override
  State<_EventFormBody> createState() => _EventFormBodyState();
}

class _EventFormBodyState extends State<_EventFormBody> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _when = TextEditingController();
  String? _titleError;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _when.dispose();
    super.dispose();
  }

  void _submit() {
    final t = _title.text.trim();
    if (t.isEmpty) {
      setState(() => _titleError = 'Añade un título');
      return;
    }
    setState(() => _titleError = null);
    LocalActionService.createEvent(
      title: t,
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      dateText: _when.text.trim().isEmpty ? null : _when.text.trim(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: LocalActionFormSheet._paddingFor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LocalActionFormSheet._sheetTitle(context, 'Nuevo evento'),
          const FormSectionTitle('Título'),
          AppTextField(
            controller: _title,
            hint: 'Ej. Revisión de diseño',
            errorText: _titleError,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          const FormSectionTitle('Descripción'),
          AppTextField(
            controller: _description,
            maxLines: 3,
            hint: 'Notas del evento',
          ),
          const SizedBox(height: AppSpacing.md),
          const FormSectionTitle('Fecha u hora (texto libre)'),
          AppTextField(
            controller: _when,
            hint: 'Ej. Mañana 10:00',
          ),
          const SizedBox(height: AppSpacing.xl),
          AppFormButton(label: 'Crear evento', onPressed: _submit),
          const SizedBox(height: AppSpacing.sm),
          AppFormButton(
            label: 'Cancelar',
            primary: false,
            onPressed: () => Navigator.of(context).pop(),
          ),
          SizedBox(height: scheme.brightness == Brightness.dark ? 8 : 0),
        ],
      ),
    );
  }
}

class _MailFormBody extends StatefulWidget {
  const _MailFormBody();

  @override
  State<_MailFormBody> createState() => _MailFormBodyState();
}

class _MailFormBodyState extends State<_MailFormBody> {
  final _subject = TextEditingController();
  final _body = TextEditingController();
  String? _subjectError;

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  void _submit() {
    final t = _subject.text.trim();
    if (t.isEmpty) {
      setState(() => _subjectError = 'Añade un asunto');
      return;
    }
    setState(() => _subjectError = null);
    LocalActionService.createMailAction(
      title: t,
      description: _body.text.trim().isEmpty ? null : _body.text.trim(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: LocalActionFormSheet._paddingFor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LocalActionFormSheet._sheetTitle(context, 'Acción de correo'),
          const FormSectionTitle('Asunto'),
          AppTextField(
            controller: _subject,
            hint: 'Ej. Respuesta a Ana',
            errorText: _subjectError,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          const FormSectionTitle('Descripción'),
          AppTextField(
            controller: _body,
            maxLines: 4,
            hint: 'Resumen o borrador simulado',
          ),
          const SizedBox(height: AppSpacing.xl),
          AppFormButton(label: 'Crear acción', onPressed: _submit),
          const SizedBox(height: AppSpacing.sm),
          AppFormButton(
            label: 'Cancelar',
            primary: false,
            onPressed: () => Navigator.of(context).pop(),
          ),
          SizedBox(height: scheme.brightness == Brightness.dark ? 8 : 0),
        ],
      ),
    );
  }
}
