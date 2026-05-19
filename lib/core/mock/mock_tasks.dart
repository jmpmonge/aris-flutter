import '../models/task_model.dart';

abstract final class MockTasks {
  static List<TaskModel> today() {
    final t = DateTime.now();
    return [
      TaskModel(
        id: 'mock_task_meeting',
        title: 'Preparar reunión lunes',
        completed: false,
        dueDate: DateTime(t.year, t.month, t.day),
      ),
      TaskModel(
        id: 'mock_task_cloud',
        title: 'Pagar suscripción cloud',
        completed: true,
        dueDate: DateTime(t.year, t.month, t.day),
      ),
      TaskModel(
        id: 'mock_task_mail',
        title: 'Revisar borrador de correo',
        completed: false,
        dueDate: DateTime(t.year, t.month, t.day),
      ),
      TaskModel(
        id: 'mock_task_call',
        title: 'Llamar al proveedor',
        completed: false,
        dueDate: DateTime(t.year, t.month, t.day),
      ),
      TaskModel(
        id: 'mock_task_report',
        title: 'Enviar informe trimestral',
        completed: false,
        dueDate: DateTime(t.year, t.month, t.day),
      ),
      TaskModel(
        id: 'mock_task_review',
        title: 'Revisar presupuesto Q2',
        completed: false,
        dueDate: DateTime(t.year, t.month, t.day),
      ),
    ];
  }

  static List<TaskModel> upcoming() {
    return const [
      TaskModel(
        id: 'mock_task_rest',
        title: 'Reservar restaurante (mock)',
        completed: false,
      ),
      TaskModel(
        id: 'mock_task_docs',
        title: 'Actualizar documentación',
        completed: false,
      ),
    ];
  }

  /// Títulos para el resumen Home (fallback si no hay candidatas en buckets).
  static List<TaskModel> homeHighlights() {
    return today();
  }
}
