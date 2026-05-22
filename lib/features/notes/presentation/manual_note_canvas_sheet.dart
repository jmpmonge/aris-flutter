import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/note_model.dart';
import '../../../core/repositories/repositories.dart';
import '../../../core/services/local_action_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import 'widgets/note_body_format.dart';
import 'widgets/note_checklist_line.dart';
import 'widgets/note_editor_blocks.dart';
import 'widgets/note_prose_block_field.dart';
import 'widgets/note_table_block_editor.dart';
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
  final List<NoteChecklistLineState> _checklistLines = [];
  final List<NoteEditorBlock> _blocks = [];
  int _nextChecklistLineId = 0;
  int _nextTableBlockId = 0;
  int _nextProseBlockId = 0;
  final _titleFocus = FocusNode();
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
    for (final item in parsed.checklist) {
      _checklistLines.add(_newChecklistLine(item));
    }
    if (parsed.segments.isEmpty) {
      _blocks.add(NoteEditorBlock.prose(_newProseBlock()));
    } else {
      for (final segment in parsed.segments) {
        if (segment.isProse) {
          _blocks.add(NoteEditorBlock.prose(_newProseBlock(segment.text!)));
        } else {
          _blocks.add(
            NoteEditorBlock.table(_newTableBlock(segment.table!)),
          );
        }
      }
    }
    if (widget._isNew) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _titleFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _titleFocus.dispose();
    for (final line in _checklistLines) {
      line.dispose();
    }
    for (final block in _blocks) {
      if (block.isProse) {
        block.prose!.dispose();
      } else {
        block.table!.dispose();
      }
    }
    super.dispose();
  }

  NoteProseBlockState _newProseBlock([String text = '']) {
    return NoteProseBlockState(
      id: 'pb-${_nextProseBlockId++}',
      text: text,
    );
  }

  NoteTableBlockState _newTableBlock(NoteTableBlock data) {
    return NoteTableBlockState(
      id: 'tb-${_nextTableBlockId++}',
      data: data,
    );
  }

  List<NoteBodySegment> get _segmentsSnapshot => [
        for (final block in _blocks)
          if (block.isProse)
            NoteBodySegment.prose(block.prose!.controller.text)
          else
            NoteBodySegment.table(block.table!.snapshot()),
      ];

  int? _focusedProseIndex() {
    for (var i = 0; i < _blocks.length; i++) {
      final block = _blocks[i];
      if (block.isProse && block.prose!.focusNode.hasFocus) {
        return i;
      }
    }
    return null;
  }

  NoteProseBlockState? get _firstProseBlock {
    for (final block in _blocks) {
      if (block.isProse) return block.prose;
    }
    return null;
  }

  NoteChecklistLineState _newChecklistLine(NoteChecklistItem item) {
    final line = NoteChecklistLineState(
      id: 'cl-${_nextChecklistLineId++}',
      item: item,
    );
    line.controller.addListener(() {
      line.item = line.item.copyWith(text: line.controller.text);
    });
    return line;
  }

  List<NoteChecklistItem> get _checklistSnapshot => [
        for (final line in _checklistLines)
          NoteChecklistItem(text: line.controller.text, done: line.item.done),
      ];

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
        checklist: _checklistSnapshot,
        segments: _segmentsSnapshot,
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
    final line = _newChecklistLine(const NoteChecklistItem(text: ''));
    setState(() => _checklistLines.add(line));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) line.focusNode.requestFocus();
    });
  }

  void _insertChecklistAfter(int index) {
    final line = _newChecklistLine(const NoteChecklistItem(text: ''));
    setState(() => _checklistLines.insert(index + 1, line));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) line.focusNode.requestFocus();
    });
  }

  void _toggleChecklistLine(int index) {
    setState(() {
      final line = _checklistLines[index];
      line.item = line.item.copyWith(done: !line.item.done);
    });
  }

  void _insertTable() {
    final proseIndex = _focusedProseIndex();
    if (proseIndex != null) {
      _insertTableAtProse(proseIndex);
      return;
    }
    setState(() {
      _blocks.add(NoteEditorBlock.table(_newTableBlock(NoteTableBlock.empty())));
    });
  }

  void _insertTableAtProse(int index) {
    final prose = _blocks[index].prose!;
    final controller = prose.controller;
    final selection = controller.selection;
    final offset = selection.isValid && selection.baseOffset >= 0
        ? selection.baseOffset.clamp(0, controller.text.length)
        : controller.text.length;
    final text = controller.text;
    final before = text.substring(0, offset);
    final after = text.substring(offset);

    setState(() {
      controller.text = before;
      _blocks.insert(
        index + 1,
        NoteEditorBlock.table(_newTableBlock(NoteTableBlock.empty())),
      );
      _blocks.insert(index + 2, NoteEditorBlock.prose(_newProseBlock(after)));
    });
  }

  void _writeBelowTable(int tableIndex) {
    if (tableIndex + 1 < _blocks.length && _blocks[tableIndex + 1].isProse) {
      final prose = _blocks[tableIndex + 1].prose!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) prose.focusNode.requestFocus();
      });
      return;
    }

    final prose = _newProseBlock('');
    setState(() {
      _blocks.insert(tableIndex + 1, NoteEditorBlock.prose(prose));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) prose.focusNode.requestFocus();
    });
  }

  void _addTableRow(int blockIndex) {
    final table = _blocks[blockIndex].table!;
    setState(() => table.addRow());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) table.focusCell(table.rowCount - 1, 0);
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
                        onSubmitted: (_) =>
                            _firstProseBlock?.focusNode.requestFocus(),
                        decoration: _fieldDecoration('Título'),
                      ),
                      if (_checklistLines.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        for (var i = 0; i < _checklistLines.length; i++)
                          NoteChecklistLine(
                            key: ValueKey(_checklistLines[i].id),
                            controller: _checklistLines[i].controller,
                            focusNode: _checklistLines[i].focusNode,
                            done: _checklistLines[i].item.done,
                            enabled: !_saving,
                            onToggle: () => _toggleChecklistLine(i),
                            onEnter: () => _insertChecklistAfter(i),
                          ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      for (var i = 0; i < _blocks.length; i++) ...[
                        if (i > 0)
                          SizedBox(
                            height: _blocks[i].isTable || _blocks[i - 1].isTable
                                ? AppSpacing.lg
                                : AppSpacing.md,
                          ),
                        if (_blocks[i].isProse)
                          NoteProseBlockField(
                            key: ValueKey(_blocks[i].prose!.id),
                            controller: _blocks[i].prose!.controller,
                            focusNode: _blocks[i].prose!.focusNode,
                            enabled: !_saving,
                            minLines: i == _blocks.length - 1 ? 8 : 1,
                            hintText: i == 0 && _blocks.length == 1
                                ? 'Escribe la nota…'
                                : null,
                          )
                        else
                          NoteTableBlockEditor(
                            key: ValueKey(_blocks[i].table!.id),
                            state: _blocks[i].table!,
                            enabled: !_saving,
                            onExitBelow: () => _writeBelowTable(i),
                            onTapBelow: () => _writeBelowTable(i),
                            onAddRow: () => _addTableRow(i),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              NoteWideEditorToolbar(
                checklistActive: _checklistLines.isNotEmpty,
                onChecklist: _addChecklistItem,
                onAttach: () => _placeholderTool('Adjuntar'),
                onTable: _insertTable,
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
