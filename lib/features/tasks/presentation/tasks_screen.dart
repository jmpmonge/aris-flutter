import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/task_model.dart';
import '../../../core/models/task_ui_buckets.dart';
import '../../../core/repositories/repositories.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/local_action_form_sheet.dart';
import '../../../theme/app_spacing.dart';
import 'widgets/compact_expandable_task_tile.dart';

/// Tareas desde **GET /tasks** · tarjetas compactas y desplegables (v0.47.34).
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key, this.initialExpandedTaskId});

  /// Al abrir desde Home (HOY): expandir la misma tarea por id.
  final String? initialExpandedTaskId;

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final Set<String> _busyTaskIds = <String>{};
  final Map<String, bool> _localCompletionOverride = <String, bool>{};

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

  Future<void> _deleteBackendTask(TaskModel t) async {
    final scheme = Theme.of(context).colorScheme;
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: const Text('¿Quieres eliminar esta tarea?'),
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
        _briefSnack(context, message: 'No he podido eliminar la tarea.', error: true);
      }
    } finally {
      if (mounted) setState(() => _busyTaskIds.remove(t.id));
    }
  }

  TaskGroupedLists _effectiveGrouped() {
    final now = DateTime.now();
    final base = Repositories.task.groupedForUi(now);
    if (_localCompletionOverride.isEmpty) return base;
    final agg = [
      ...base.today,
      ...base.upcoming,
      ...base.noDate,
      ...base.completed,
    ];
    final byId = <String, TaskModel>{for (final t in agg) t.id: t};
    for (final e in _localCompletionOverride.entries) {
      final cur = byId[e.key];
      if (cur != null) {
        byId[e.key] = cur.copyWith(completed: e.value);
      }
    }
    return TaskGroupedLists.partition(byId.values.toList(), now);
  }

  @override
  void initState() {
    super.initState();
    unawaited(Repositories.task.refreshFromBackend());
    Repositories.task.readRevision.addListener(_onTaskReads);
  }

  @override
  void dispose() {
    Repositories.task.readRevision.removeListener(_onTaskReads);
    super.dispose();
  }

  void _onTaskReads() {
    _localCompletionOverride.clear();
    if (mounted) setState(() {});
  }

  Future<void> _onTaskCheckbox(TaskModel t, bool? nextCompleted) async {
    if (nextCompleted == null) return;

    final online = Repositories.task.readsFromBackend;

    if (!online) {
      _localCompletionOverride[t.id] = nextCompleted;
      if (mounted) setState(() {});
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

  Widget _buildSection(
    BuildContext context,
    TaskBucketSection bucket,
    List<TaskModel> rows,
  ) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Text(
            bucket.uiLabel,
            style: text.labelSmall?.copyWith(
              letterSpacing: 1.1,
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ...rows.map(
          (t) => Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: CompactExpandableTaskTile(
              task: t,
              section: bucket,
              initiallyExpanded: widget.initialExpandedTaskId == t.id,
              busy: _busyTaskIds.contains(t.id),
              onCheckboxChanged: (v) => _onTaskCheckbox(t, v),
              onDelete: Repositories.task.readsFromBackend
                  ? () => _deleteBackendTask(t)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final grouped = _effectiveGrouped();
    final sections = grouped.nonEmptySectionsInOrder();

    Widget bodyChildren() {
      if (!grouped.hasAnyTask) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xxl,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Center(
            child: Text(
              'No tienes tareas.',
              style: text.titleMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final row in sections) _buildSection(context, row.$1, row.$2),
          const SizedBox(height: AppSpacing.fabStackClearance),
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
              subtitle: 'Lista unificada · pulsa una tarea para ampliar',
              trailing: IconButton.filledTonal(
                onPressed: () => LocalActionFormSheet.showTaskForm(context),
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Nueva tarea',
              ),
            ),
          ),
          SliverToBoxAdapter(child: bodyChildren()),
        ],
      ),
    );
  }
}
