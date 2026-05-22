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
import 'widgets/note_editor_snapshot.dart';
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
  final Set<String> _watchedProseAfterTableIds = {};
  final Set<String> _keptProseBelowTableIds = {};
  final _titleFocus = FocusNode();
  final List<NoteEditorSnapshot> _undoStack = [];
  final List<NoteEditorSnapshot> _redoStack = [];
  late NoteEditorSnapshot _historyPresent;
  Timer? _historyDebounce;
  bool _historyPaused = false;
  final List<VoidCallback> _editListenerRemovers = [];
  bool _saving = false;
  bool _pinned = false;

  bool get _canUndo => _undoStack.isNotEmpty;
  bool get _canRedo => _redoStack.isNotEmpty;

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
    for (var i = 0; i < _blocks.length; i++) {
      if (_isProseRightAfterTable(i)) {
        _watchProseAfterTable(i);
      }
    }
    _historyPresent = _captureSnapshot();
    _attachEditListeners();
    if (widget._isNew) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _titleFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _historyDebounce?.cancel();
    _detachEditListeners();
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

  /// Separación mínima entre bloques; tras tabla, sin hueco extra antes del texto.
  double _gapBeforeBlock(int index) {
    assert(index > 0);
    final prev = _blocks[index - 1];
    final curr = _blocks[index];
    if (prev.isTable && curr.isProse) return 0;
    if (prev.isProse && curr.isTable) return AppSpacing.xs;
    if (prev.isTable || curr.isTable) return AppSpacing.xs;
    return AppSpacing.md;
  }

  int _proseMinLines(int index) {
    final afterTable = index > 0 && _blocks[index - 1].isTable;
    if (afterTable) return 1;
    final onlyBlock = _blocks.length == 1;
    if (onlyBlock && index == 0) return 8;
    return 1;
  }

  bool _isProseRightAfterTable(int index) {
    return index > 0 && _blocks[index].isProse && _blocks[index - 1].isTable;
  }

  void _watchProseAfterTable(int index) {
    final prose = _blocks[index].prose!;
    if (!_watchedProseAfterTableIds.add(prose.id)) return;

    void onFocusOrText() {
      if (!mounted) return;
      final idx = _blocks.indexWhere(
        (b) => b.isProse && identical(b.prose, prose),
      );
      if (idx < 0 || !_isProseRightAfterTable(idx)) return;

      if (prose.focusNode.hasFocus ||
          prose.controller.text.trim().isNotEmpty ||
          _keptProseBelowTableIds.contains(prose.id)) {
        setState(() {});
        return;
      }

      setState(() {
        prose.dispose();
        _blocks.removeAt(idx);
        _watchedProseAfterTableIds.remove(prose.id);
      });
    }

    prose.focusNode.addListener(onFocusOrText);
    prose.controller.addListener(onFocusOrText);
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

  NoteEditorSnapshot _captureSnapshot() => NoteEditorSnapshot.fromDocument(
        title: _title.text,
        checklist: _checklistSnapshot,
        segments: _segmentsSnapshot,
      );

  void _attachEditListeners() {
    void listen(VoidCallback handler) {
      _editListenerRemovers.add(handler);
    }

    void onEdit() => _scheduleHistoryRecord();

    _title.addListener(onEdit);
    listen(() => _title.removeListener(onEdit));

    for (final line in _checklistLines) {
      line.controller.addListener(onEdit);
      listen(() => line.controller.removeListener(onEdit));
    }
    for (final block in _blocks) {
      if (block.isProse) {
        block.prose!.controller.addListener(onEdit);
        listen(() => block.prose!.controller.removeListener(onEdit));
      } else {
        for (final row in block.table!.rowControllers) {
          for (final cell in row) {
            cell.addListener(onEdit);
            listen(() => cell.removeListener(onEdit));
          }
        }
      }
    }
  }

  void _detachEditListeners() {
    for (final remove in _editListenerRemovers) {
      remove();
    }
    _editListenerRemovers.clear();
  }

  void _scheduleHistoryRecord() {
    if (_historyPaused) return;
    _historyDebounce?.cancel();
    _historyDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted || _historyPaused) return;
      _commitHistoryRecord();
    });
  }

  void _commitHistoryRecord() {
    final snap = _captureSnapshot();
    if (snap == _historyPresent) return;
    _undoStack.add(_historyPresent);
    _historyPresent = snap;
    _redoStack.clear();
    setState(() {});
  }

  void _recordHistoryBeforeMutation() {
    if (_historyPaused) return;
    _historyDebounce?.cancel();
    final snap = _captureSnapshot();
    if (snap == _historyPresent) return;
    _undoStack.add(_historyPresent);
    _historyPresent = snap;
    _redoStack.clear();
  }

  void _undo() {
    if (!_canUndo) return;
    _historyPaused = true;
    _historyDebounce?.cancel();
    final current = _captureSnapshot();
    _redoStack.add(current);
    final previous = _undoStack.removeLast();
    _historyPresent = previous;
    _restoreFromSnapshot(previous);
    _historyPaused = false;
    setState(() {});
  }

  void _redo() {
    if (!_canRedo) return;
    _historyPaused = true;
    _historyDebounce?.cancel();
    final current = _captureSnapshot();
    _undoStack.add(current);
    final next = _redoStack.removeLast();
    _historyPresent = next;
    _restoreFromSnapshot(next);
    _historyPaused = false;
    setState(() {});
  }

  void _clearEditorContent() {
    _detachEditListeners();
    for (final line in _checklistLines) {
      line.dispose();
    }
    _checklistLines.clear();
    for (final block in _blocks) {
      if (block.isProse) {
        block.prose!.dispose();
      } else {
        block.table!.dispose();
      }
    }
    _blocks.clear();
    _watchedProseAfterTableIds.clear();
    _keptProseBelowTableIds.clear();
  }

  void _restoreFromSnapshot(NoteEditorSnapshot snap) {
    _historyPaused = true;
    _clearEditorContent();
    _title.text = snap.title;
    for (final item in snap.checklist) {
      _checklistLines.add(_newChecklistLine(item));
    }
    if (snap.segments.isEmpty) {
      _blocks.add(NoteEditorBlock.prose(_newProseBlock()));
    } else {
      for (final segment in snap.segments) {
        if (segment.isProse) {
          _blocks.add(NoteEditorBlock.prose(_newProseBlock(segment.text!)));
        } else {
          _blocks.add(
            NoteEditorBlock.table(_newTableBlock(segment.table!)),
          );
        }
      }
    }
    for (var i = 0; i < _blocks.length; i++) {
      if (_isProseRightAfterTable(i)) {
        _watchProseAfterTable(i);
      }
    }
    _historyPaused = false;
    _attachEditListeners();
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

  Future<void> _onOk() async {
    if (_saving) return;
    final ok = await _persist();
    if (!mounted) return;
    if (ok || widget._isNew) {
      Navigator.of(context).pop();
    } else {
      _briefSnack(_noteBackendFail);
    }
  }

  Future<void> _onBack() => _onOk();

  void _placeholderTool(String feature) {
    _briefSnack('$feature · próximamente');
  }

  void _addChecklistItem() {
    _recordHistoryBeforeMutation();
    final line = _newChecklistLine(const NoteChecklistItem(text: ''));
    setState(() => _checklistLines.add(line));
    _attachEditListenersForChecklistLine(line);
    _commitHistoryRecord();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) line.focusNode.requestFocus();
    });
  }

  void _insertChecklistAfter(int index) {
    _recordHistoryBeforeMutation();
    final line = _newChecklistLine(const NoteChecklistItem(text: ''));
    setState(() => _checklistLines.insert(index + 1, line));
    _attachEditListenersForChecklistLine(line);
    _commitHistoryRecord();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) line.focusNode.requestFocus();
    });
  }

  /// Intro en línea con texto → nueva fila; Intro en línea vacía → sale al cuerpo libre.
  void _onChecklistEnter(int index) {
    final line = _checklistLines[index];
    if (line.controller.text.trim().isEmpty) {
      _exitChecklistAt(index);
      return;
    }
    _insertChecklistAfter(index);
  }

  void _exitChecklistAt(int index) {
    _recordHistoryBeforeMutation();
    final line = _checklistLines[index];
    setState(() {
      line.dispose();
      _checklistLines.removeAt(index);
    });
    _commitHistoryRecord();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _firstProseBlock?.focusNode.requestFocus();
    });
  }

  void _attachEditListenersForChecklistLine(NoteChecklistLineState line) {
    void onEdit() => _scheduleHistoryRecord();
    line.controller.addListener(onEdit);
    _editListenerRemovers.add(() => line.controller.removeListener(onEdit));
  }

  void _toggleChecklistLine(int index) {
    _recordHistoryBeforeMutation();
    setState(() {
      final line = _checklistLines[index];
      line.item = line.item.copyWith(done: !line.item.done);
    });
    _commitHistoryRecord();
  }

  void _insertTable() {
    final proseIndex = _focusedProseIndex();
    if (proseIndex != null) {
      _insertTableAtProse(proseIndex);
      return;
    }
    _recordHistoryBeforeMutation();
    setState(() {
      _blocks.add(NoteEditorBlock.table(_newTableBlock(NoteTableBlock.empty())));
    });
    _attachEditListenersForTable(_blocks.last.table!);
    _commitHistoryRecord();
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

    _recordHistoryBeforeMutation();
    setState(() {
      controller.text = before;
      _blocks.insert(
        index + 1,
        NoteEditorBlock.table(_newTableBlock(NoteTableBlock.empty())),
      );
      if (after.isNotEmpty) {
        final proseIndex = index + 2;
        final prose = _newProseBlock(after);
        _blocks.insert(proseIndex, NoteEditorBlock.prose(prose));
        _keptProseBelowTableIds.add(prose.id);
        _watchProseAfterTable(proseIndex);
        _attachEditListenersForProse(prose);
      }
    });
    _attachEditListenersForTable(_blocks[index + 1].table!);
    _commitHistoryRecord();
  }

  void _exitTableBelow(int tableIndex) {
    final table = _blocks[tableIndex].table!;
    if (table.isLastRowEmpty) {
      setState(() => table.removeLastRowIfEmpty());
    }
    _writeBelowTable(tableIndex);
  }

  void _writeBelowTable(int tableIndex) {
    if (tableIndex + 1 < _blocks.length && _blocks[tableIndex + 1].isProse) {
      final proseIndex = tableIndex + 1;
      final prose = _blocks[proseIndex].prose!;
      _keptProseBelowTableIds.add(prose.id);
      _watchProseAfterTable(proseIndex);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) prose.focusNode.requestFocus();
      });
      return;
    }

    _recordHistoryBeforeMutation();
    final prose = _newProseBlock('');
    final insertIndex = tableIndex + 1;
    setState(() {
      _blocks.insert(insertIndex, NoteEditorBlock.prose(prose));
    });
    _keptProseBelowTableIds.add(prose.id);
    _watchProseAfterTable(insertIndex);
    _attachEditListenersForProse(prose);
    _commitHistoryRecord();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) prose.focusNode.requestFocus();
    });
  }

  void _addTableRow(int blockIndex) {
    final table = _blocks[blockIndex].table!;
    _recordHistoryBeforeMutation();
    setState(() => table.addRow());
    _attachEditListenersForTable(table);
    _commitHistoryRecord();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) table.focusCell(table.rowCount - 1, 0);
    });
  }

  void _attachEditListenersForProse(NoteProseBlockState prose) {
    void onEdit() => _scheduleHistoryRecord();
    prose.controller.addListener(onEdit);
    _editListenerRemovers.add(() => prose.controller.removeListener(onEdit));
  }

  void _attachEditListenersForTable(NoteTableBlockState table) {
    void onEdit() => _scheduleHistoryRecord();
    for (final row in table.rowControllers) {
      for (final cell in row) {
        cell.addListener(onEdit);
        _editListenerRemovers.add(() => cell.removeListener(onEdit));
      }
    }
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
              leading: const Icon(Icons.ios_share_rounded),
              title: const Text('Compartir'),
              onTap: () {
                Navigator.pop(ctx);
                _placeholderTool('Compartir');
              },
            ),
            ListTile(
              leading: Icon(
                _pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              ),
              title: Text(_pinned ? 'Desfijar nota' : 'Fijar nota'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _pinned = !_pinned);
              },
            ),
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
              leading: const Icon(Icons.copy_outlined),
              title: const Text('Duplicar'),
              onTap: () {
                Navigator.pop(ctx);
                _placeholderTool('Duplicar');
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
                saving: _saving,
                canUndo: _canUndo,
                canRedo: _canRedo,
                onBack: _onBack,
                onUndo: _undo,
                onRedo: _redo,
                onMore: _showMoreMenu,
                onOk: _onOk,
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
                            onEnter: () => _onChecklistEnter(i),
                          ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      for (var i = 0; i < _blocks.length; i++) ...[
                        if (i > 0) SizedBox(height: _gapBeforeBlock(i)),
                        if (_blocks[i].isProse)
                          NoteProseBlockField(
                            key: ValueKey(_blocks[i].prose!.id),
                            controller: _blocks[i].prose!.controller,
                            focusNode: _blocks[i].prose!.focusNode,
                            enabled: !_saving,
                            minLines: _proseMinLines(i),
                            hintText: i == 0 && _blocks.length == 1
                                ? 'Escribe la nota…'
                                : null,
                          )
                        else
                          NoteTableBlockEditor(
                            key: ValueKey(_blocks[i].table!.id),
                            state: _blocks[i].table!,
                            enabled: !_saving,
                            onExitBelow: () => _exitTableBelow(i),
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
    required this.saving,
    required this.canUndo,
    required this.canRedo,
    required this.onBack,
    required this.onUndo,
    required this.onRedo,
    required this.onMore,
    required this.onOk,
  });

  final bool saving;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onBack;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onMore;
  final VoidCallback onOk;

  static const Color _disabledIcon = Color(0x66A6B0BE);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
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
            onPressed: saving || !canUndo ? null : onUndo,
            icon: Icon(
              Icons.undo_rounded,
              size: 22,
              color: canUndo && !saving
                  ? AppColors.noteArisBlue
                  : _disabledIcon,
            ),
            tooltip: 'Deshacer',
          ),
          IconButton(
            onPressed: saving || !canRedo ? null : onRedo,
            icon: Icon(
              Icons.redo_rounded,
              size: 22,
              color: canRedo && !saving
                  ? AppColors.noteArisBlue
                  : _disabledIcon,
            ),
            tooltip: 'Rehacer',
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
          TextButton(
            onPressed: saving ? null : onOk,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.noteArisBlue,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: const Size(44, 40),
            ),
            child: Text(
              'OK',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: saving ? _disabledIcon : AppColors.noteArisBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
