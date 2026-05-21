import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/note_model.dart';
import '../../../core/repositories/repositories.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/home_aris_reply_card.dart';
import 'manual_note_canvas_sheet.dart';
import '../../../theme/app_spacing.dart';

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
    final scheme = Theme.of(context).colorScheme;
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
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.xs,
                  ),
                  child: Text(
                    'Recientes',
                    style: text.labelSmall?.copyWith(
                      letterSpacing: 1.1,
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
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
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: AppCard(
                          onTap: () =>
                              ManualNoteCanvasSheet.openExisting(context, n),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(n.title, style: text.titleSmall),
                                    if (n.body.isNotEmpty) ...[
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        n.body,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: text.bodyMedium?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (Repositories.note.readsFromBackend)
                                PopupMenuButton<String>(
                                  tooltip: 'Más opciones',
                                  enabled: !_busyNoteIds.contains(n.id),
                                  onSelected: (v) => _onRecentNoteMenu(v, n),
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Eliminar'),
                                    ),
                                  ],
                                ),
                            ],
                          ),
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
