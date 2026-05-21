import 'package:flutter/material.dart';

import '../../../core/services/local_action_service.dart';
import '../../../theme/app_spacing.dart';

/// Lienzo manual de nota: solo título y cuerpo, sin etiquetas (v0.49.14–15).
abstract final class ManualNoteCanvasSheet {
  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const _ManualNoteCanvasPage(),
      ),
    );
  }
}

class _ManualNoteCanvasPage extends StatefulWidget {
  const _ManualNoteCanvasPage();

  @override
  State<_ManualNoteCanvasPage> createState() => _ManualNoteCanvasPageState();
}

class _ManualNoteCanvasPageState extends State<_ManualNoteCanvasPage> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _bodyFocus = FocusNode();

  static const double _titleDividerGap = 10;
  static const double _bodyTopGap = 14;

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

  void _save() {
    final t = _title.text.trim();
    if (t.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Escribe un título en la primera línea.'),
        ),
      );
      return;
    }
    LocalActionService.createNote(
      title: t,
      content: _body.text.trim(),
    );
    Navigator.of(context).pop();
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
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Cerrar',
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton.filledTonal(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded),
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
