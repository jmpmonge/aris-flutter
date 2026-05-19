import '../../../../core/models/event_model.dart';
import '../../../../core/models/task_model.dart';

/// Sugerencia breve bajo el saludo en Home — solo si hay datos relevantes.
abstract final class HomeContextualInsight {
  static String? from({
    required List<EventModel> events,
    required List<TaskModel> tasks,
  }) {
    final eventCount = events.length;
    final pending =
        tasks.where((t) => !t.completed).toList(growable: false);
    final pendingCount = pending.length;

    if (eventCount > 0 && pendingCount > 0) {
      final ev = eventCount == 1 ? 'evento' : 'eventos';
      final ta = pendingCount == 1 ? 'tarea pendiente' : 'tareas pendientes';
      return 'Tienes $eventCount $ev y $pendingCount $ta.';
    }

    if (eventCount > 0) {
      final ev = eventCount == 1 ? 'evento' : 'eventos';
      return 'Tienes $eventCount $ev hoy.';
    }

    if (pendingCount == 0) return null;

    final undated = pending
        .where(
          (t) =>
              (t.dateIso == null || t.dateIso!.trim().isEmpty) &&
              (t.dateText == null || t.dateText!.trim().isEmpty) &&
              t.dueDate == null,
        )
        .length;

    if (undated == 1) {
      return 'Hay 1 tarea sin fecha que podrías ordenar.';
    }
    if (undated > 1) {
      return 'Hay $undated tareas sin fecha que podrías ordenar.';
    }

    final ta = pendingCount == 1 ? 'tarea pendiente' : 'tareas pendientes';
    return 'Tienes $pendingCount $ta.';
  }
}
