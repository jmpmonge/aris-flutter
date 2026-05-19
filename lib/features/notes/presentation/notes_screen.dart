import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/local_action_model.dart';
import '../../../core/models/note_model.dart';
import '../../../core/repositories/repositories.dart';
import '../../../core/services/local_action_service.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/app_search_bar.dart';
import '../../../shared/widgets/local_action_card.dart';
import '../../../shared/widgets/local_action_empty_state.dart';
import '../../../shared/widgets/local_action_form_sheet.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../theme/app_spacing.dart';

/// Notas — buscador, notas rápidas y lista **mock**.
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final Set<String> _busyNoteIds = <String>{};

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
    LocalActionService.revision.addListener(_onArisActions);
    Repositories.note.readRevision.addListener(_onNoteReads);
  }

  @override
  void dispose() {
    Repositories.note.readRevision.removeListener(_onNoteReads);
    LocalActionService.revision.removeListener(_onArisActions);
    super.dispose();
  }

  void _onNoteReads() {
    if (mounted) setState(() {});
  }

  void _onArisActions() {
    if (mounted) setState(() {});
  }

  Future<void> _onRecentNoteMenu(String action, NoteModel n) async {
    switch (action) {
      case 'edit':
        await _editBackendNote(n);
      case 'delete':
        await _deleteBackendNote(n);
      default:
        break;
    }
  }

  Future<void> _editBackendNote(NoteModel n) async {
    final titleCtrl = TextEditingController(text: n.title);
    final bodyCtrl = TextEditingController(text: n.body);

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dlgScheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: const Text('Editar nota'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Título (se envía junto al texto)',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: dlgScheme.outline),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: bodyCtrl,
                  minLines: 3,
                  maxLines: 8,
                  decoration: InputDecoration(
                    labelText: 'Contenido',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: dlgScheme.outline),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    final tt = titleCtrl.text.trim();
    final bb = bodyCtrl.text.trim();
    titleCtrl.dispose();
    bodyCtrl.dispose();

    if (saved != true || !mounted) return;
    if (tt.isEmpty && bb.isEmpty) {
      _briefSnack(context, message: _noteBackendFail, error: true);
      return;
    }

    setState(() => _busyNoteIds.add(n.id));
    try {
      final ok = await Repositories.note.updateNote(
        n.id,
        title: tt.isEmpty ? null : tt,
        content: bb.isEmpty ? null : bb,
      );
      if (!mounted) return;
      if (ok) {
        _briefSnack(context, message: 'Nota actualizada.');
      } else {
        _briefSnack(context, message: _noteBackendFail, error: true);
      }
    } finally {
      if (mounted) setState(() => _busyNoteIds.remove(n.id));
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
    final quick = Repositories.note.getQuickLabels();
    final recent = Repositories.note.getRecentNotes();
    final arisNotes =
        LocalActionService.getActionsByType(LocalActionType.note);

    return SafeArea(
      top: true,
      bottom: false,
      child: Column(
        key: const Key('tab_notes'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppHeader(
            title: 'Notas',
            subtitle: 'Servidor PATCH/DELETE cuando hay GET OK · demo si no',
          ),
          const AppSearchBar(hintText: 'Buscar en notas…', readOnly: true),
          SectionTitle(
            title: 'Notas rápidas',
            actionLabel: 'Nueva nota',
            onAction: () {
              LocalActionFormSheet.showNoteForm(context);
            },
          ),
          SizedBox(
            height: AppSpacing.quickChipsStripHeight,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              scrollDirection: Axis.horizontal,
              itemCount: quick.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
              itemBuilder: (context, i) {
                return ActionChip(
                  label: Text(quick[i]),
                  side: BorderSide(
                    color: scheme.outline.withValues(alpha: 0.35),
                  ),
                  onPressed: () {},
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Text(
              'Notas creadas por Aris',
              style: text.labelSmall?.copyWith(
                letterSpacing: 1.1,
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (arisNotes.isEmpty)
            const LocalActionEmptyState(
              message:
                  'Sin notas desde el chat ni desde el formulario. Pulsa «Nueva nota» arriba.',
            )
          else
            SizedBox(
              height: 132,
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                scrollDirection: Axis.horizontal,
                itemCount: arisNotes.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, i) {
                  return SizedBox(
                    width: 280,
                    child: LocalActionCard(
                      action: arisNotes[i],
                      compact: true,
                    ),
                  );
                },
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
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.fabStackClearance,
              ),
              itemCount: recent.length,
              itemBuilder: (context, i) {
                final n = recent[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(n.title, style: text.titleSmall),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    n.body,
                                    style: text.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
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
                                    value: 'edit',
                                    child: Text('Editar'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Eliminar'),
                                  ),
                                ],
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
    );
  }
}
