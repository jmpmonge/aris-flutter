import 'package:flutter/material.dart';

import '../../core/services/local_action_service.dart';
import '../../features/notes/presentation/manual_note_canvas_sheet.dart';
import '../../features/tasks/presentation/manual_task_editor_page.dart';
import '../../theme/app_spacing.dart';
import '../layout/breakpoints.dart';
import 'app_form_button.dart';
import 'app_text_field.dart';
import 'form_section_title.dart';

/// Formularios modales (bottom sheet): tareas contra backend (v0.47.33+);
/// otros tipos pueden seguir usando acciones locales de demostración.
abstract final class LocalActionFormSheet {
  static Future<void> showTaskForm(BuildContext context) {
    return ManualTaskEditorPage.show(context);
  }

  /// Lienzo manual de nota (v0.49.14).
  static Future<void> showManualNoteForm(BuildContext context) {
    return ManualNoteCanvasSheet.show(context);
  }

  static Future<void> showNoteForm(BuildContext context) {
    return showManualNoteForm(context);
  }

  static Future<void> showEventForm(BuildContext context) {
    return _open(context, const _EventFormBody());
  }

  static Future<void> showMailForm(BuildContext context) {
    return _open(context, const _MailFormBody());
  }

  static Future<void> _open(BuildContext context, Widget body) {
    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final sheetConstraints = width > LayoutBreakpoints.webMobileFrameMaxWidth
        ? BoxConstraints(
            maxWidth: LayoutBreakpoints.webMobileFrameMaxWidth,
          )
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
      builder: (ctx) => body,
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

  static Widget _sheetHeader(
    BuildContext context,
    String title, {
    String? subtitle,
  }) {
    final theme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            subtitle ??
                'Aris · contenido solo en este dispositivo (simulado)',
            style: theme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
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
          LocalActionFormSheet._sheetHeader(context, 'Nuevo evento con Aris'),
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
          LocalActionFormSheet._sheetHeader(
            context,
            'Acción de correo con Aris',
          ),
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
          AppFormButton(label: 'Crear acción simulada', onPressed: _submit),
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
