import '../models/local_action_model.dart';
import '../models/task_model.dart';
import '../services/local_action_service.dart';
import '../services/task_service.dart';

/// Contrato de tareas (mock + acciones locales). Implementación: [LocalTaskRepository].
abstract interface class TaskRepository {
  List<TaskModel> getTodayTasks();

  List<TaskModel> getUpcomingTasks();

  List<TaskModel> getHomeHighlightTasks();

  List<LocalActionModel> getLocalTasks();

  LocalActionModel createLocalTask({
    required String title,
    String? description,
    LocalTaskPriority? priority,
  });

  void toggleLocalTaskCompleted(String id);

  void removeLocalTask(String id);
}

final class LocalTaskRepository implements TaskRepository {
  @override
  List<TaskModel> getTodayTasks() => TaskService.getTodayTasks();

  @override
  List<TaskModel> getUpcomingTasks() => TaskService.getUpcomingTasks();

  @override
  List<TaskModel> getHomeHighlightTasks() => TaskService.getHomeHighlightTasks();

  @override
  List<LocalActionModel> getLocalTasks() {
    return LocalActionService.getActionsByType(LocalActionType.task);
  }

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
  void toggleLocalTaskCompleted(String id) {
    LocalActionService.toggleActionCompleted(id);
  }

  @override
  void removeLocalTask(String id) {
    LocalActionService.removeAction(id);
  }
}
