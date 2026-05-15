import '../mock/mock_tasks.dart';
import '../models/task_model.dart';

abstract final class TaskService {
  static List<TaskModel> getTodayTasks() => MockTasks.today();

  static List<TaskModel> getUpcomingTasks() => MockTasks.upcoming();

  static List<TaskModel> getHomeHighlightTasks() => MockTasks.homeHighlights();
}
