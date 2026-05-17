import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/local_action_model.dart';
import '../../../core/repositories/repositories.dart';
import '../../../core/services/local_action_service.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/local_action_card.dart';
import '../../../shared/widgets/local_action_empty_state.dart';
import '../../../shared/widgets/local_action_form_sheet.dart';
import '../../../theme/app_spacing.dart';
import '../../../core/models/task_model.dart';

/// Tareas — hoy y próximas, estados mock (sin persistencia).
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late List<TaskModel> _today;
  late List<TaskModel> _upcoming;
  final Set<String> _busyTaskIds = <String>{};

  static const _taskBackendFail =
      'No he podido actualizar la tarea. Revisa la conexión con el backend.';

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
        backgroundColor: error ? scheme.error : scheme.surfaceContainerHighest,
        content: Text(
          message,
          style: TextStyle(
            color: error ? scheme.onError : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  void _reloadTaskListsFromRepository() {
    _today = List<TaskModel>.from(Repositories.task.getTodayTasks());
    _upcoming = List<TaskModel>.from(Repositories.task.getUpcomingTasks());
  }

  @override
  void initState() {
    super.initState();
    _reloadTaskListsFromRepository();
    unawaited(Repositories.task.refreshFromBackend());
    LocalActionService.revision.addListener(_onLocalActions);
    Repositories.task.readRevision.addListener(_onTaskReads);
  }

  @override
  void dispose() {
    Repositories.task.readRevision.removeListener(_onTaskReads);
    LocalActionService.revision.removeListener(_onLocalActions);
    super.dispose();
  }

  void _onTaskReads() {
    if (!mounted) return;
    setState(_reloadTaskListsFromRepository);
  }

  void _onLocalActions() {
    if (mounted) setState(() {});
  }

  void _applyLocalCompletion(TaskModel t, bool completed) {
    setState(() {
      void bump(List<TaskModel> list) {
        final i = list.indexWhere((e) => e.id == t.id);
        if (i >= 0) list[i] = list[i].copyWith(completed: completed);
      }

      bump(_today);
      bump(_upcoming);
    });
  }

  Future<void> _onTaskCheckbox(TaskModel t, bool? nextCompleted) async {
    if (nextCompleted == null) return;

    final fromBackend = Repositories.task.readsFromBackend;

    if (!fromBackend) {
      _applyLocalCompletion(t, nextCompleted);
      return;
    }

    if (_busyTaskIds.contains(t.id)) return;

    debugPrint(
      '[TaskList] checkbox taskId=${t.id} '
      'wasCompleted=${t.completed} nextCompleted=$nextCompleted',
    );

    setState(() => _busyTaskIds.add(t.id));
    try {
      final ok = await Repositories.task.setTaskCompleted(t.id, nextCompleted);
      if (!mounted) return;
      if (ok) {
        _briefSnack(
          context,
          message: nextCompleted
              ? 'Tarea completada.'
              : 'Tarea marcada como pendiente.',
        );
      } else {
        _briefSnack(context, message: _taskBackendFail, error: true);
      }
    } finally {
      if (mounted) {
        setState(() => _busyTaskIds.remove(t.id));
      }
    }
  }

  Future<void> _confirmDeleteBackendTask(TaskModel t) async {
    final scheme = Theme.of(context).colorScheme;
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Eliminar esta tarea del servidor?'),
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

    setState(() => _busyTaskIds.add(t.id));
    try {
      final ok = await Repositories.task.deleteTask(t.id);
      if (!mounted) return;
      if (ok) {
        _briefSnack(context, message: 'Tarea eliminada.');
      } else {
        _briefSnack(context, message: _taskBackendFail, error: true);
      }
    } finally {
      if (mounted) setState(() => _busyTaskIds.remove(t.id));
    }
  }

  Future<void> _editBackendTask(TaskModel t) async {
    final titleCtrl = TextEditingController(text: t.title);

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dlgScheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: const Text('Editar tarea'),
          content: TextField(
            controller: titleCtrl,
            autofocus: true,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Título (PATCH /tasks/{id})',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: dlgScheme.outline),
              ),
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

    final nextTitle = titleCtrl.text.trim();
    titleCtrl.dispose();
    if (saved != true || !mounted) return;
    if (nextTitle.isEmpty) {
      _briefSnack(context, message: _taskBackendFail, error: true);
      return;
    }

    setState(() => _busyTaskIds.add(t.id));
    try {
      final ok = await Repositories.task.updateTask(t.id, title: nextTitle);
      if (!mounted) return;
      if (ok) {
        _briefSnack(context, message: 'Cambios guardados.');
      } else {
        _briefSnack(context, message: _taskBackendFail, error: true);
      }
    } finally {
      if (mounted) setState(() => _busyTaskIds.remove(t.id));
    }
  }

  Future<void> _onTaskOverflow(String action, TaskModel t) async {
    switch (action) {
      case 'edit':
        await _editBackendTask(t);
      case 'delete':
        await _confirmDeleteBackendTask(t);
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    Widget section(String title, List<TaskModel> items) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Text(
              title,
              style: text.labelSmall?.copyWith(
                letterSpacing: 1.1,
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...List.generate(items.length, (i) {
            final t = items[i];
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Card(
                elevation: Theme.of(context).cardTheme.elevation ?? 2,
                shadowColor: Theme.of(context).cardTheme.shadowColor,
                shape: Theme.of(context).cardTheme.shape,
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  minVerticalPadding: AppSpacing.sm,
                  leading: Checkbox(
                    visualDensity: VisualDensity.compact,
                    value: t.completed,
                    onChanged: _busyTaskIds.contains(t.id)
                        ? null
                        : Repositories.task.readsFromBackend
                        ? (v) => _onTaskCheckbox(t, v)
                        : (v) => _onTaskCheckbox(t, v),
                  ),
                  title: Text(
                    t.title,
                    style: text.bodyLarge?.copyWith(
                      decoration: t.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: t.completed
                          ? scheme.onSurfaceVariant
                          : scheme.onSurface,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        t.completed
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: t.completed
                            ? scheme.secondary
                            : scheme.onSurfaceVariant,
                      ),
                      if (Repositories.task.readsFromBackend)
                        PopupMenuButton<String>(
                          tooltip: 'Más opciones',
                          enabled: !_busyTaskIds.contains(t.id),
                          onSelected: (v) => _onTaskOverflow(v, t),
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Editar'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Eliminar'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      );
    }

    return SafeArea(
      top: true,
      bottom: false,
      child: CustomScrollView(
        key: const Key('tab_tasks'),
        slivers: [
          SliverToBoxAdapter(
            child: AppHeader(
              title: 'Tareas',
              subtitle:
                  'Marcar/desmarcar servidor · menú más opciones cuando hay datos GET',
              trailing: IconButton.filledTonal(
                onPressed: () => LocalActionFormSheet.showTaskForm(context),
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Nueva tarea',
              ),
            ),
          ),
          SliverToBoxAdapter(child: section('HOY', _today)),
          SliverToBoxAdapter(child: section('PRÓXIMAS', _upcoming)),
          SliverToBoxAdapter(child: _arisTasksSection(context)),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.fabStackClearance),
          ),
        ],
      ),
    );
  }

  Widget _arisTasksSection(BuildContext context) {
    final arisTasks = LocalActionService.getActionsByType(LocalActionType.task);

    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Text(
            'Creadas por Aris',
            style: text.labelSmall?.copyWith(
              letterSpacing: 1.1,
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (arisTasks.isEmpty)
          const LocalActionEmptyState(
            message:
                'Nada aquí todavía. Usa el botón + arriba o escribe en Inicio (p. ej. «recuérdame…»).',
          )
        else
          ...List.generate(arisTasks.length, (i) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: LocalActionCard(action: arisTasks[i]),
            );
          }),
      ],
    );
  }
}
