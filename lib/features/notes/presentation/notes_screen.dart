import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/note_model.dart';
import '../../../core/repositories/repositories.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/home_aris_reply_card.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/aris_list_palette.dart';
import '../../../theme/app_spacing.dart';
import 'manual_note_canvas_sheet.dart';
import 'widgets/note_list_card.dart';

/// Notas — creación manual (+), listado y canal Aris (sin tags visibles, v0.49.15).
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final Set<String> _busyNoteIds = <String>{};
  bool _arisSending = false;

  static const _noteBackendFail =
      'No he podido actualizar la nota. Revisa la conexión con el backend.';

  void _briefSnack(
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
  @override
  void initState() {
    super.initState();
    unawaited(Repositories.note.refreshFromBackend());
    Repositories.note.readRevision.addListener(_onNoteReads);
  }

  @override
  void dispose() {
    Repositories.note.readRevision.removeListener(_onNoteReads);
    super.dispose();
  }

  void _onNoteReads() {
    if (mounted) setState(() {});
  }

  double _listBottomPadding(BuildContext context) {
    return HomeArisFixedInputBar.dockHeight +
        AppSpacing.sm +
        AppSpacing.homeScrollBottomBreathing;
  }

  Future<void> _sendArisMessage(String text) async {
    final t = text.trim();
    if (t.isEmpty) return;

    setState(() => _arisSending = true);
    await Repositories.assistant.sendMessage(t);
    if (!mounted) return;
    setState(() => _arisSending = false);
  }

  void _onMicPressed() {
    Repositories.assistant.sendVoicePendingNotice();
  }

  void _onNoteTap(NoteModel n) {
    unawaited(ManualNoteCanvasSheet.openExisting(context, n));
  }

  Future<void> _onRecentNoteMenu(String action, NoteModel n) async {
    if (action == 'delete') {
      await _deleteBackendNote(n);
    }
  }

  Future<void> _deleteBackendNote(NoteModel n) async {
    final scheme = Theme.of(context).colorScheme;
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar nota'),
        content: const Text('¿Eliminar esta nota del servidor?'),
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

    setState(() => _busyNoteIds.add(n.id));
    try {
      final ok = await Repositories.note.deleteNote(n.id);
      if (!mounted) return;
      if (ok) {
        _briefSnack(context, message: 'Nota eliminada.');
      } else {
        _briefSnack(context, message: _noteBackendFail, error: true);
      }
    } finally {
      if (mounted) setState(() => _busyNoteIds.remove(n.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final recent = Repositories.note.getRecentNotes();

    return SafeArea(
      top: true,
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              key: const Key('tab_notes'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppHeader(
                  title: 'Notas',
                  trailing: IconButton.filledTonal(
                    onPressed: () => ManualNoteCanvasSheet.show(context),
                    icon: const Icon(Icons.add_rounded),
                    tooltip: 'Nueva nota',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.xs,
                  ),
                  child: Text(
                    'Recientes',
                    style: text.labelSmall?.copyWith(
                      fontSize: 12,
                      letterSpacing: 0.6,
                      color: context.arisList.noteSectionLabel,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      _listBottomPadding(context),
                    ),
                    itemCount: recent.length,
                    itemBuilder: (context, i) {
                      final n = recent[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: NoteListCard(
                          note: n,
                          onTap: () => _onNoteTap(n),
                          trailing: Repositories.note.readsFromBackend
                              ? PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_horiz_rounded,
                                    size: 20,
                                    color: AppColors.noteWideTextMuted,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  tooltip: 'Más opciones',
                                  enabled: !_busyNoteIds.contains(n.id),
                                  onSelected: (v) => _onRecentNoteMenu(v, n),
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Eliminar'),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          HomeArisFixedInputBar(
            hintText: 'Pide a Aris crear o buscar notas…',
            isSending: _arisSending,
            onSubmit: _sendArisMessage,
            onMicPressed: _onMicPressed,
          ),
        ],
      ),
    );
  }
}
