import 'package:flutter/material.dart';

import '../../../core/models/note_model.dart';
import '../../../core/repositories/repositories.dart';
import '../../../core/services/local_action_service.dart';
import '../../../theme/app_spacing.dart';

/// Lienzo de nota: creación manual o apertura inside de existente (v0.49.16).
abstract final class ManualNoteCanvasSheet {
  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const _ManualNoteCanvasPage(),
      ),
    );
  }

  static Future<void> openExisting(BuildContext context, NoteModel note) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _ManualNoteCanvasPage(existing: note),
      ),
    );
  }
}

class _ManualNoteCanvasPage extends StatefulWidget {
  const _ManualNoteCanvasPage({this.existing});

  final NoteModel? existing;

  bool get _isNew => existing == null;

  @override
  State<_ManualNoteCanvasPage> createState() => _ManualNoteCanvasPageState();
}

class _ManualNoteCanvasPageState extends State<_ManualNoteCanvasPage> {
  late final TextEditingController _title;
  late final TextEditingController _body;
  final _bodyFocus = FocusNode();
  bool _saving = false;

  static const _noteBackendFail =
      'No he podido guardar la nota. Revisa la conexión con el backend.';

  static const double _titleDividerGap = 10;
  static const double _bodyTopGap = 14;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.existing?.title ?? '');
    _body = TextEditingController(text: widget.existing?.body ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _bodyFocus.dispose();
    super.dispose();
  }

  InputDecoration _borderlessHint(
    BuildContext context, {
    required String hint,
    TextStyle? hintStyle,
  }) {
    return InputDecoration(
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      filled: false,
      hintText: hint,
      hintStyle: hintStyle,
      contentPadding: EdgeInsets.zero,
      isDense: true,
    );
  }

  void _briefSnack(String message, {bool error = false}) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    final scheme = Theme.of(context).colorScheme;
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            error ? scheme.error : scheme.surfaceContainerHighest,
        content: Text(
          message,
          style: TextStyle(
            color: error ? scheme.onError : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final t = _title.text.trim();
    final b = _body.text.trim();
    if (t.isEmpty) {
      _briefSnack('Escribe un título en la primera línea.');
      return;
    }
    if (_saving) return;

    setState(() => _saving = true);
    try {
      if (widget._isNew) {
        LocalActionService.createNote(title: t, content: b);
        if (!mounted) return;
        Navigator.of(context).pop();
        return;
      }

      if (Repositories.note.readsFromBackend) {
        final ok = await Repositories.note.updateNote(
          widget.existing!.id,
          title: t,
          content: b.isEmpty ? null : b,
        );
        if (!mounted) return;
        if (ok) {
          Navigator.of(context).pop();
        } else {
          _briefSnack(_noteBackendFail, error: true);
        }
        return;
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final titleStyle = text.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
      height: 1.25,
      color: scheme.onSurface,
    );
    final bodyStyle = text.bodyLarge?.copyWith(
      height: 1.5,
      color: scheme.onSurface,
    );
    final titleHintStyle = titleStyle?.copyWith(
      color: scheme.onSurfaceVariant.withValues(alpha: 0.55),
      fontWeight: FontWeight.w600,
    );
    final bodyHintStyle = bodyStyle?.copyWith(
      color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
    );

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Volver',
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton.filledTonal(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.onSecondaryContainer,
                    ),
                  )
                : const Icon(Icons.check_rounded),
            tooltip: 'Guardar nota',
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _title,
                style: titleStyle,
                maxLines: 1,
                enabled: !_saving,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _bodyFocus.requestFocus(),
                decoration: _borderlessHint(
                  context,
                  hint: 'Título',
                  hintStyle: titleHintStyle,
                ),
              ),
              const SizedBox(height: _titleDividerGap),
              Divider(
                height: 1,
                thickness: 1,
                color: scheme.primary.withValues(alpha: 0.32),
              ),
              const SizedBox(height: _bodyTopGap),
              Expanded(
                child: TextField(
                  controller: _body,
                  focusNode: _bodyFocus,
                  style: bodyStyle,
                  enabled: !_saving,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  decoration: _borderlessHint(
                    context,
                    hint: 'Escribe la nota…',
                    hintStyle: bodyHintStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
