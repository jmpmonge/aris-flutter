/// Contenido de demostración para [HomeScreen]. Sin lógica de UI.
abstract final class HomeMockContent {
  static String greetingForNow() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días, José';
    if (h < 20) return 'Buenas tardes, José';
    return 'Buenas noches, José';
  }

  static const summary =
      'Tienes 12 tareas pendientes y 2 eventos esta tarde. Respira: es un resumen simulado para diseño.';

  static const suggestion =
      'Revisa tus tareas pendientes antes del fin de semana.';

  static const events = [
    '15:30 · Revisión médica anual (Centro Norte, mock)',
    '18:00 · Recoger paquete en locker',
  ];

  static const tasks = [
    'Responder al equipo de diseño',
    'Llamar a papá antes de cenar',
    'Enviar borrador del informe',
  ];

  static const notes = [
    'Idea: playlist “concentración suave”',
    'Nota: regalo cumple Ana (libro)',
  ];
}
