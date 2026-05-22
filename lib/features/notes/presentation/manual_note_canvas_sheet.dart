import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/note_model.dart';
import '../../../core/repositories/repositories.dart';
import '../../../core/services/local_action_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import 'widgets/note_body_format.dart';
import 'widgets/note_wide_editor_toolbar.dart';

/// Lienzo de nota amplia — estilo Apple Notes / Aris oscuro (v0.49.41).
abstract final class ManualNoteCanvasSheet {
  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const _NoteWideEditorPage(),
      ),
    );
  }

  static Future<void> openExisting(BuildContext context, NoteModel note) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _NoteWideEditorPage(existing: note),
      ),
    );
  }
}

class _NoteWideEditorPage extends StatefulWidget {
  const _NoteWideEditorPage({this.existing});

  final NoteModel? existing;

  bool get _isNew => existing == null;

  @override
  State<_NoteWideEditorPage> createState() => _NoteWideEditorPageState();
}

class _NoteWideEditorPageState extends State<_NoteWideEditorPage> {
  late final TextEditingController _title;
  late final TextEditingController _prose;
  late List<NoteChecklistItem> _checklist;
  final _titleFocus = FocusNode();
  final _proseFocus = FocusNode();
  bool _saving = false;
  bool _pinned = false;

  static const _noteBackendFail =
      'No he podido guardar la nota. Revisa la conexión con el backend.';

  static const double _horizontalPad = 20;

  @override
  void initState() {
    super.initState();
    final parsed = NoteBodyFormat.parse(widget.existing?.body ?? '');
    _title = TextEditingController(text: widget.existing?.title ?? '');
    _prose = TextEditingController(text: parsed.prose);
    _checklist = List<NoteChecklistItem>.from(parsed.checklist);
    if (widget._isNew) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _titleFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _prose.dispose();
    _titleFocus.dispose();
    _proseFocus.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      filled: false,
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.noteWideTextMuted,
        fontWeight: FontWeight.w500,
      ),
      contentPadding: EdgeInsets.zero,
      isCollapsed: true,
    );
  }

  void _briefSnack(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.noteWideSurface,
        content: Text(
          message,
          style: const TextStyle(color: AppColors.noteWideTextSecondary),
        ),
      ),
    );
  }

  String _mergedBody() => NoteBodyFormat.merge(
        checklist: _checklist,
        prose: _prose.text,
      );

  Future<bool> _persist() async {
    var t = _title.text.trim();
    if (t.isEmpty) t = 'Sin título';
    final b = _mergedBody();
    if (_saving) return false;

    setState(() => _saving = true);
    try {
      if (widget._isNew) {
        LocalActionService.createNote(title: t, content: b);
        return true;
      }

      if (Repositories.note.readsFromBackend) {
        return await Repositories.note.updateNote(
          widget.existing!.id,
          title: t,
          content: b.isEmpty ? null : b,
        );
      }
      return true;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _onBack() async {
    if (_saving) return;
    final ok = await _persist();
    if (!mounted) return;
    if (ok || widget._isNew) {
      Navigator.of(context).pop();
    } else {
      _briefSnack(_noteBackendFail);
    }
  }

  void _placeholderTool(String feature) {
    _briefSnack('$feature · próximamente');
  }

  void _addChecklistItem() {
    setState(() {
      _checklist = [..._checklist, const NoteChecklistItem(text: '')];
    });
  }

  void _showArisActions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.noteWideSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_outlined,
                    color: AppColors.noteArisBlue,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Preguntar a Aris',
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          color: AppColors.noteWideTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            for (final label in const [
              'Resumir nota',
              'Extraer tareas',
              'Convertir en evento',
              'Mejorar redacción',
              'Buscar ideas clave',
              'Preguntar sobre esta nota',
            ])
              ListTile(
                title: Text(
                  label,
                  style: const TextStyle(color: AppColors.noteWideTextSecondary),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _placeholderTool(label);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showMoreMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.noteWideSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.label_outline_rounded),
              title: const Text('Etiquetas'),
              onTap: () {
                Navigator.pop(ctx);
                _placeholderTool('Etiquetas');
              },
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_move_outline),
              title: const Text('Mover a carpeta'),
              onTap: () {
                Navigator.pop(ctx);
                _placeholderTool('Mover');
              },
            ),
            ListTile(
              leading: Icon(
                _pinned ? Icons.push_pin : Icons.push_pin_outlined,
              ),
              title: Text(_pinned ? 'Desfijar' : 'Fijar nota'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _pinned = !_pinned);
              },
            ),
            ListTile(
              leading: const Icon(Icons.task_alt_outlined),
              title: const Text('Convertir en tarea'),
              onTap: () {
                Navigator.pop(ctx);
                _placeholderTool('Convertir en tarea');
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_outlined),
              title: const Text('Convertir en evento'),
              onTap: () {
                Navigator.pop(ctx);
                _placeholderTool('Convertir en evento');
              },
            ),
            if (!widget._isNew)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.noteDestructive,
                ),
                title: const Text(
                  'Eliminar',
                  style: TextStyle(color: AppColors.noteDestructive),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    if (widget._isNew) {
      Navigator.of(context).pop();
      return;
    }
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.noteWideSurface,
        title: const Text('Eliminar nota'),
        content: const Text('¿Eliminar esta nota?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    if (Repositories.note.readsFromBackend) {
      final ok = await Repositories.note.deleteNote(widget.existing!.id);
      if (!mounted) return;
      if (ok) Navigator.of(context).pop();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(
      fontSize: 28,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      color: AppColors.noteWideTextPrimary,
    );
    const bodyStyle = TextStyle(
      fontSize: 17,
      height: 1.55,
      fontWeight: FontWeight.w400,
      color: AppColors.noteWideTextPrimary,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_onBack());
      },
      child: Scaffold(
        backgroundColor: AppColors.noteWideCanvas,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _NoteWideTopBar(
                pinned: _pinned,
                saving: _saving,
                onBack: _onBack,
                onTogglePin: () => setState(() => _pinned = !_pinned),
                onShare: () => _placeholderTool('Compartir'),
                onMore: _showMoreMenu,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    _horizontalPad,
                    8,
                    _horizontalPad,
                    16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _title,
                        focusNode: _titleFocus,
                        style: titleStyle,
                        maxLines: null,
                        enabled: !_saving,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _proseFocus.requestFocus(),
                        decoration: _fieldDecoration('Título'),
                      ),
                      if (_checklist.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        ..._checklist.asMap().entries.map(
                          (e) => _ChecklistRow(
                            key: ValueKey(
                              'check-${e.key}-${e.value.done}-${e.value.text}',
                            ),
                            item: e.value,
                            onTextChanged: (v) {
                              setState(() {
                                _checklist[e.key] =
                                    e.value.copyWith(text: v);
                              });
                            },
                            onToggle: () {
                              setState(() {
                                _checklist[e.key] = e.value.copyWith(
                                  done: !e.value.done,
                                );
                              });
                            },
                            onRemove: () {
                              setState(() {
                                _checklist = List<NoteChecklistItem>.from(
                                  _checklist,
                                )..removeAt(e.key);
                              });
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _prose,
                        focusNode: _proseFocus,
                        style: bodyStyle,
                        enabled: !_saving,
                        minLines: 12,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: _fieldDecoration('Escribe la nota…'),
                      ),
                    ],
                  ),
                ),
              ),
              NoteWideEditorToolbar(
                checklistActive: _checklist.isNotEmpty,
                onChecklist: _addChecklistItem,
                onAttach: () => _placeholderTool('Adjuntar'),
                onTable: () => _placeholderTool('Tabla'),
                onScan: () => _placeholderTool('Escanear / OCR'),
                onAris: _showArisActions,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteWideTopBar extends StatelessWidget {
  const _NoteWideTopBar({
    required this.pinned,
    required this.saving,
    required this.onBack,
    required this.onTogglePin,
    required this.onShare,
    required this.onMore,
  });

  final bool pinned;
  final bool saving;
  final VoidCallback onBack;
  final VoidCallback onTogglePin;
  final VoidCallback onShare;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: saving ? null : onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: AppColors.noteWideTextSecondary,
            ),
            tooltip: 'Volver',
          ),
          const Spacer(),
          IconButton(
            onPressed: saving ? null : onTogglePin,
            icon: Icon(
              pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              size: 22,
              color: pinned
                  ? AppColors.noteArisBlue
                  : AppColors.noteWideTextSecondary,
            ),
            tooltip: pinned ? 'Desfijar' : 'Fijar',
          ),
          IconButton(
            onPressed: saving ? null : onShare,
            icon: const Icon(
              Icons.ios_share_rounded,
              size: 22,
              color: AppColors.noteWideTextSecondary,
            ),
            tooltip: 'Compartir',
          ),
          IconButton(
            onPressed: saving ? null : onMore,
            icon: const Icon(
              Icons.more_horiz_rounded,
              size: 24,
              color: AppColors.noteWideTextSecondary,
            ),
            tooltip: 'Más opciones',
          ),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatefulWidget {
  const _ChecklistRow({
    super.key,
    required this.item,
    required this.onTextChanged,
    required this.onToggle,
    required this.onRemove,
  });

  final NoteChecklistItem item;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  @override
  State<_ChecklistRow> createState() => _ChecklistRowState();
}

class _ChecklistRowState extends State<_ChecklistRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.text);
  }

  @override
  void didUpdateWidget(covariant _ChecklistRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.text != widget.item.text &&
        _controller.text != widget.item.text) {
      _controller.text = widget.item.text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final done = widget.item.done;
    final textColor =
        done ? AppColors.noteWideTextMuted : AppColors.noteWideTextPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: widget.onToggle,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    done
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    size: 20,
                    color: done
                        ? AppColors.noteArisBlue
                        : AppColors.noteWideTextMuted,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onTextChanged,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                color: textColor,
                decoration: done ? TextDecoration.lineThrough : null,
                decorationColor: AppColors.noteWideTextMuted,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          IconButton(
            onPressed: widget.onRemove,
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
              color: AppColors.noteWideTextMuted,
            ),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
