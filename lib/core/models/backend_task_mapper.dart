import 'backend_date_hints.dart';
import 'task_model.dart';

/// Mapper tolerante desde filas **`/tasks`** del backend.
abstract final class BackendTaskMapper {
  static TaskModel? tryParse(Map<String, dynamic> m) {
    try {
      final id = _str(m['id']).isEmpty
          ? 'task_${identityHashCode(m)}'
          : _str(m['id']);
      final titleBase =
          _str(m['title']).trim().isEmpty ? 'Tarea' : _str(m['title']).trim();

      final descTrim = _str(m['description']).trim();
      final description = descTrim.isEmpty ? null : descTrim;

      final tags = <String>[];
      final tagsRaw = m['tags'];
      if (tagsRaw is List) {
        for (final x in tagsRaw) {
          final sx = x.toString().trim();
          if (sx.isNotEmpty) tags.add(sx);
        }
      }

      final prTrim = _str(m['priority']).trim();
      final priority = prTrim.isEmpty ? null : prTrim;

      final dateIsoTrim = _str(m['date_iso']).trim();
      final dateIso = dateIsoTrim.isEmpty ? null : dateIsoTrim;

      final dateTextTrim = _str(m['date_text']).trim();
      final dateText = dateTextTrim.isEmpty ? null : dateTextTrim;

      final timeTrim = _str(m['time_text']).trim();
      final timeText = timeTrim.isEmpty ? null : timeTrim;

      final completed = _truthyCompleted(m['completed']);

      final dueFromCalendar =
          BackendDateTimeHints.parseDateFlexible(dateIso ?? dateText);
      DateTime? dueDate;
      if (dueFromCalendar != null) {
        final dd = dueFromCalendar.toUtc();
        dueDate =
            DateTime.utc(dd.year, dd.month, dd.day).toLocal();
      }

      return TaskModel(
        id: id,
        title: titleBase,
        completed: completed,
        dueDate: dueDate,
        description: description,
        tags: tags,
        priority: priority,
        dateIso: dateIso,
        dateText: dateText,
        timeText: timeText,
      );
    } on Object {
      return null;
    }
  }

  static String _str(Object? v) => v?.toString() ?? '';

  static bool _truthyCompleted(Object? v) {
    if (v is bool) return v;
    final s = v?.toString().toLowerCase().trim();
    return s == 'true' || s == '1' || s == 'yes' || s == 'sí' || s == 'si';
  }

  /// Sin **created_at**: la partición de pantalla usa `date_iso` / `date_text`.
  ///
  /// Se mantiene por compatibilidad con código viejo (**no usar** para la UI v0.47.34+).
  static void partitionForUi({
    required List<TaskModel> all,
    required DateTime now,
    required List<TaskModel> outToday,
    required List<TaskModel> outUpcoming,
  }) {
    outToday.clear();
    outUpcoming.clear();

    DateTime sod(DateTime d) => DateTime(d.year, d.month, d.day);

    final t0 = sod(now.toLocal());

    for (final t in all) {
      if (t.completed) {
        outUpcoming.add(t);
        continue;
      }

      final dDue = t.dueDate?.toLocal();
      final sodDue = dDue != null ? sod(dDue) : null;

      if (sodDue == null) {
        outToday.add(t);
      } else {
        final cmp = sodDue.compareTo(t0);
        if (cmp < 0) {
          outToday.add(t);
        } else if (cmp == 0) {
          outToday.add(t);
        } else {
          outUpcoming.add(t);
        }
      }
    }

    void sortLo(List<TaskModel> xs) {
      xs.sort((a, b) {
        final c = (a.completed == b.completed)
            ? 0
            : (a.completed ? 1 : -1);
        if (c != 0) return c;
        final da = a.dueDate ?? DateTime(2100);
        final db = b.dueDate ?? DateTime(2100);
        return da.compareTo(db);
      });
    }

    sortLo(outToday);
    sortLo(outUpcoming);
  }
}
