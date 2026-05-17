import 'backend_date_hints.dart';
import 'task_model.dart';

enum TaskBucketSection { today, upcoming, noDate, completed }

extension TaskBucketSectionX on TaskBucketSection {
  String get uiLabel => switch (this) {
        TaskBucketSection.today => 'HOY',
        TaskBucketSection.upcoming => 'PRÓXIMAS',
        TaskBucketSection.noDate => 'SIN FECHA',
        TaskBucketSection.completed => 'COMPLETADAS',
      };
}

abstract final class TaskCompactFormat {
  static String compactMetaLine(
    TaskModel t,
    TaskBucketSection section,
    DateTime now,
  ) {
    final parts = <String>[];
    final nowSod = DateTime(now.year, now.month, now.day);

    DateTime? isoLocal;
    if (t.dateIso != null && t.dateIso!.trim().isNotEmpty) {
      isoLocal = TaskModel.tryParseIsoDateLocal(t.dateIso);
    }

    final rawTxt = (t.dateText ?? '').trim();
    String? cal;

    if (rawTxt.isNotEmpty) {
      cal = rawTxt;
    } else if (isoLocal != null) {
      final sameAsToday = _sameDay(isoLocal, nowSod);
      final hideNumeric =
          section == TaskBucketSection.today && sameAsToday;
      if (!hideNumeric) {
        cal =
            '${isoLocal.day.toString().padLeft(2, '0')}/${isoLocal.month.toString().padLeft(2, '0')}';
      }
    }

    final timeTxt = (t.timeText ?? '').trim();
    if (cal != null && cal.isNotEmpty) parts.add(cal);
    if (timeTxt.isNotEmpty) parts.add(timeTxt);
    return parts.join(' · ');
  }

  static bool priorityHigh(TaskModel t) =>
      (t.priority ?? '').trim().toLowerCase() == 'high';

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Agrupación de filas **`/tasks`** (sin NLP adicional sobre `date_text`).
class TaskGroupedLists {
  TaskGroupedLists({
    required this.today,
    required this.upcoming,
    required this.noDate,
    required this.completed,
  });

  final List<TaskModel> today;
  final List<TaskModel> upcoming;
  final List<TaskModel> noDate;
  final List<TaskModel> completed;

  factory TaskGroupedLists.empty() =>
      TaskGroupedLists(today: [], upcoming: [], noDate: [], completed: []);

  bool get hasAnyTask =>
      today.isNotEmpty ||
      upcoming.isNotEmpty ||
      noDate.isNotEmpty ||
      completed.isNotEmpty;

  Iterable<(TaskBucketSection, List<TaskModel>)>
      nonEmptySectionsInOrder() sync* {
    if (today.isNotEmpty) yield (TaskBucketSection.today, today);
    if (upcoming.isNotEmpty) yield (TaskBucketSection.upcoming, upcoming);
    if (noDate.isNotEmpty) yield (TaskBucketSection.noDate, noDate);
    if (completed.isNotEmpty) yield (TaskBucketSection.completed, completed);
  }

  static TaskGroupedLists partition(List<TaskModel> all, DateTime nowLocal) {
    final t = <TaskModel>[];
    final u = <TaskModel>[];
    final n = <TaskModel>[];
    final c = <TaskModel>[];

    for (final task in all) {
      switch (_classify(task, nowLocal)) {
        case TaskBucketSection.completed:
          c.add(task);
        case TaskBucketSection.today:
          t.add(task);
        case TaskBucketSection.upcoming:
          u.add(task);
        case TaskBucketSection.noDate:
          n.add(task);
      }
    }

    void sortIncomplete(List<TaskModel> xs) {
      xs.sort((a, b) {
        final ac =
            '${a.dateIso ?? ''}-${a.dateText ?? ''}-${a.timeText ?? ''}-${a.title}';
        final bc =
            '${b.dateIso ?? ''}-${b.dateText ?? ''}-${b.timeText ?? ''}-${b.title}';
        return ac.compareTo(bc);
      });
    }

    void sortCompleted(List<TaskModel> xs) {
      xs.sort((a, b) {
        final ac = '${a.dateIso ?? ''}-${a.dateText ?? ''}-${a.title}';
        final bc = '${b.dateIso ?? ''}-${b.dateText ?? ''}-${b.title}';
        return ac.compareTo(bc);
      });
    }

    sortIncomplete(t);
    sortIncomplete(u);
    sortIncomplete(n);
    sortCompleted(c);

    return TaskGroupedLists(today: t, upcoming: u, noDate: n, completed: c);
  }

  static TaskBucketSection _classify(TaskModel task, DateTime nowLocal) {
    if (task.completed) return TaskBucketSection.completed;

    final sodNow = _startOfDay(nowLocal.toLocal());

    DateTime? civilIsoRow;
    if (task.dateIso != null && task.dateIso!.trim().isNotEmpty) {
      final fromIso = BackendDateTimeHints.parseDateFlexible(task.dateIso);
      if (fromIso != null) {
        civilIsoRow = _startOfDay(fromIso.toLocal());
      }
    }

    if (civilIsoRow != null) {
      if (civilIsoRow.isBefore(sodNow)) return TaskBucketSection.today;
      if (_isSameDay(civilIsoRow, sodNow)) return TaskBucketSection.today;
      return TaskBucketSection.upcoming;
    }

    final rawText = (task.dateText ?? '').trim();
    if (rawText.isNotEmpty) {
      final low = rawText.toLowerCase();
      if (low == 'hoy') return TaskBucketSection.today;

      final flex =
          BackendDateTimeHints.parseDateFlexible(task.dateText);
      if (flex != null) {
        final s = _startOfDay(flex.toLocal());
        if (s.isBefore(sodNow)) return TaskBucketSection.today;
        if (_isSameDay(s, sodNow)) return TaskBucketSection.today;
        return TaskBucketSection.upcoming;
      }

      return TaskBucketSection.upcoming;
    }

    final dueMock = task.dueDate?.toLocal();
    if (dueMock != null) {
      final s = _startOfDay(dueMock);
      if (s.isBefore(sodNow)) return TaskBucketSection.today;
      if (_isSameDay(s, sodNow)) return TaskBucketSection.today;
      return TaskBucketSection.upcoming;
    }

    return TaskBucketSection.noDate;
  }

  static DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
