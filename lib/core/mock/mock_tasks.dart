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

  /// Títulos para el resumen Home (subset amigable).
  static List<TaskModel> homeHighlights() {
    return const [
      TaskModel(id: 'mock_home_t1', title: 'Responder al equipo de diseño'),
      TaskModel(id: 'mock_home_t2', title: 'Llamar a papá antes de cenar'),
      TaskModel(id: 'mock_home_t3', title: 'Enviar borrador del informe'),
    ];
  }
}
