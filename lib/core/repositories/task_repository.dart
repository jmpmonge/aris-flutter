import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../models/backend_task_mapper.dart';
import '../models/local_action_model.dart';
import '../models/task_model.dart';
import '../services/local_action_service.dart';
import '../services/task_service.dart';

/// Contrato de tareas (demo local + opcional lista GET `/tasks` y mutaciones v0.42).
abstract interface class TaskRepository {
  ValueNotifier<int> get readRevision;

  /// `true` si el último GET `/tasks` tuvo éxito (lista puede estar vacía).
  bool get readsFromBackend;

  Future<bool> refreshFromBackend();

  List<TaskModel> getTodayTasks();

  List<TaskModel> getUpcomingTasks();

  List<TaskModel> getHomeHighlightTasks();

  List<LocalActionModel> getLocalTasks();

  LocalActionModel createLocalTask({
    required String title,
    String? description,
    LocalTaskPriority? priority,
  });

  /// POST **`/tasks`**: creación en servidor (sin GPT). Requiere URL base válida.
  Future<bool> createTaskOnBackend({
    required String title,
    String? description,
    String? dateText,
    String? dateIso,
    String? timeText,
    String priority = 'normal',
    List<String>? tags,
  });

  void toggleLocalTaskCompleted(String id);

  void removeLocalTask(String id);

  /// `PATCH /tasks/{id}` con **`{"completed": ...}`** (backend v0.47.31+).
  Future<bool> setTaskCompleted(String taskId, bool completed);

  /// Igual que [setTaskCompleted] con **`completed: true`**.
  Future<bool> completeTask(String taskId);

  /// Renombrar tarea en servidor — **no** implementado contra backend minimal v0.47.31
  /// (`PATCH /tasks/{id}` sólo acepta `completed`; ver [setTaskCompleted]).
  Future<bool> updateTask(String taskId, {String? title, String? description});

  Future<bool> deleteTask(String taskId);
}

final class HybridTaskRepository implements TaskRepository {
  HybridTaskRepository(this._client);

  final ApiClient _client;

  @override
  final ValueNotifier<int> readRevision = ValueNotifier<int>(0);

  bool _readsOk = false;
  List<TaskModel> _todayCached = [];
  List<TaskModel> _upcomingCached = [];

  /// Evita que un **GET /tasks** antiguo (p. ej. arranque de pantalla) pise el
  /// estado tras un **PATCH** ya aplicado.
  int _tasksFetchGeneration = 0;

  @override
  bool get readsFromBackend => _readsOk;

  void _applyTasksPayload(List<Map<String, dynamic>> rawList) {
    final mapped = <TaskModel>[];
    for (final row in rawList) {
      final t = BackendTaskMapper.tryParse(row);
      if (t != null) mapped.add(t);
    }

    final td = <TaskModel>[];
    final up = <TaskModel>[];
    BackendTaskMapper.partitionForUi(
      all: mapped,
      now: DateTime.now(),
      outToday: td,
      outUpcoming: up,
    );

    _todayCached = List<TaskModel>.from(td);
    _upcomingCached = List<TaskModel>.from(up);
  }

  void _mergePatchedTaskRow(Map<String, dynamic> row) {
    final tm = BackendTaskMapper.tryParse(row);
    if (tm == null) return;
    final mergedById = <String, TaskModel>{};
    for (final t in _todayCached) {
      mergedById[t.id] = t;
    }
    for (final t in _upcomingCached) {
      mergedById[t.id] = t;
    }
    mergedById[tm.id] = tm;
    final all = mergedById.values.toList();
    final td = <TaskModel>[];
    final up = <TaskModel>[];
    BackendTaskMapper.partitionForUi(
      all: all,
      now: DateTime.now(),
      outToday: td,
      outUpcoming: up,
    );
    _todayCached = List<TaskModel>.from(td);
    _upcomingCached = List<TaskModel>.from(up);
  }

  @override
  Future<bool> refreshFromBackend() async {
    final gen = ++_tasksFetchGeneration;
    final res = await _client.getTasks();
    if (gen != _tasksFetchGeneration) {
      debugPrint(
        '[HybridTaskRepository] refreshFromBackend omitido (GET obsoleto gen=$gen '
        'cur=$_tasksFetchGeneration)',
      );
      return _readsOk;
    }
    if (!res.isSuccess || res.data == null) {
      _readsOk = false;
      _todayCached = [];
      _upcomingCached = [];
      readRevision.value++;
      return false;
    }

    _readsOk = true;
    _applyTasksPayload(res.data!);
    readRevision.value++;
    return true;
  }

  Future<void> _reloadTasksAfterMutation() async {
    if (!_readsOk) return;

    final gen = ++_tasksFetchGeneration;
    final res = await _client.getTasks();
    if (gen != _tasksFetchGeneration) {
      debugPrint(
        '[HybridTaskRepository] _reloadTasksAfterMutation omitido (GET obsoleto '
        'gen=$gen cur=$_tasksFetchGeneration)',
      );
      return;
    }
    if (!res.isSuccess || res.data == null) {
      debugPrint(
        '[HybridTaskRepository] refresco tras mutación sin éxito, se mantiene cache previa.',
      );
      return;
    }
    _readsOk = true;
    _applyTasksPayload(res.data!);
    readRevision.value++;
  }

  @override
  List<TaskModel> getTodayTasks() {
    return _readsOk
        ? List<TaskModel>.unmodifiable(_todayCached)
        : TaskService.getTodayTasks();
  }

  @override
  List<TaskModel> getUpcomingTasks() {
    return _readsOk
        ? List<TaskModel>.unmodifiable(_upcomingCached)
        : TaskService.getUpcomingTasks();
  }

  @override
  List<TaskModel> getHomeHighlightTasks() {
    if (!_readsOk) {
      return TaskService.getHomeHighlightTasks();
    }
    final pick = <TaskModel>[
      ..._todayCached,
      ..._upcomingCached,
    ].where((t) => !t.completed).take(3).toList();
    return pick;
  }

  @override
  List<LocalActionModel> getLocalTasks() =>
      LocalActionService.getActionsByType(LocalActionType.task);

  @override
  LocalActionModel createLocalTask({
    required String title,
    String? description,
    LocalTaskPriority? priority,
  }) {
    return LocalActionService.createTask(
      title: title,
      description: description,
      priority: priority,
    );
  }

  @override
  Future<bool> createTaskOnBackend({
    required String title,
    String? description,
    String? dateText,
    String? dateIso,
    String? timeText,
    String priority = 'normal',
    List<String>? tags,
  }) async {
    if (!_client.isConfigured) {
      debugPrint('[HybridTaskRepository] createTaskOnBackend sin baseUrl');
      return false;
    }
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) return false;

    final body = <String, dynamic>{'title': trimmedTitle};
    final desc = description?.trim();
    if (desc != null && desc.isNotEmpty) body['description'] = desc;

    final dText = dateText?.trim();
    if (dText != null && dText.isNotEmpty) body['date_text'] = dText;

    final dIso = dateIso?.trim();
    if (dIso != null && dIso.isNotEmpty) body['date_iso'] = dIso;

    final tTxt = timeText?.trim();
    if (tTxt != null && tTxt.isNotEmpty) body['time_text'] = tTxt;

    final prio = priority.trim().toLowerCase() == 'high' ? 'high' : 'normal';
    body['priority'] = prio;
    body['tags'] = List<String>.from(tags ?? const <String>[]);

    final res = await _client.createTaskRaw(body);
    if (!res.isSuccess || res.data == null) {
      debugPrint('[HybridTaskRepository] createTaskOnBackend error: ${res.error}');
      return false;
    }
    _readsOk = true;
    _mergePatchedTaskRow(Map<String, dynamic>.from(res.data!));
    readRevision.value++;
    await _reloadTasksAfterMutation();
    return true;
  }

  @override
  void toggleLocalTaskCompleted(String id) {
    LocalActionService.toggleActionCompleted(id);
  }

  @override
  void removeLocalTask(String id) {
    LocalActionService.removeAction(id);
  }

  @override
  Future<bool> setTaskCompleted(String taskId, bool completed) async {
    if (!_readsOk) return false;

    debugPrint(
      '[TaskToggle] id=$taskId previousUnknown desiredCompleted=$completed '
      '(cache actual en UI)',
    );
    final res = await _client.patchTaskCompletion(taskId, completed);
    if (!res.isSuccess) {
      debugPrint('[TaskToggle] PATCH failure: ${res.error}');
      return false;
    }
    final body = res.data;
    if (body != null && body.containsKey('id')) {
      debugPrint(
        '[TaskToggle] PATCH ok body keys=${body.keys.take(12).join(",")} '
        'completed=${body['completed']}',
      );
      _mergePatchedTaskRow(Map<String, dynamic>.from(body));
      readRevision.value++;
    }

    debugPrint('[TaskToggle] lanzando GET /tasks tras mutación…');
    await _reloadTasksAfterMutation();

    debugPrint('[TaskToggle] fin setTaskCompleted (éxito HTTP PATCH)');
    return true;
  }

  @override
  Future<bool> completeTask(String taskId) => setTaskCompleted(taskId, true);

  @override
  Future<bool> updateTask(
    String taskId, {
    String? title,
    String? description,
  }) async {
    if (!_readsOk) return false;

    final res = await _client.updateTask(
      taskId,
      title: title,
      description: description,
    );
    if (!res.isSuccess) return false;

    await _reloadTasksAfterMutation();
    return true;
  }

  @override
  Future<bool> deleteTask(String taskId) async {
    if (!_readsOk) return false;

    final res = await _client.deleteTask(taskId);
    if (!res.isSuccess) return false;

    await _reloadTasksAfterMutation();
    return true;
  }
}
