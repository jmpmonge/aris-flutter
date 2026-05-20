import '../../../../core/models/chat_message_model.dart';
import '../../../../core/services/chat_service.dart';

/// Mensaje inicial si aún no hay respuesta de Aris en Home (v0.48.43).
const String kHomeArisDefaultReadyMessage =
    'Estoy listo para ayudarte con tu día.';

/// Instrucciones desde Home antes de abrir chat inside.
const int kHomeArisInstructionsBeforeInsideChat = 3;

/// Resumen del día para la tarjeta de Aris (sustituye la línea del encabezado).
String homeArisDayContextMessage({
  required int eventCount,
  required int taskCount,
}) {
  if (eventCount == 0 && taskCount == 0) {
    return kHomeArisDefaultReadyMessage;
  }

  if (eventCount > 0 && taskCount > 0) {
    final events =
        eventCount == 1 ? '1 evento' : '$eventCount eventos';
    final tasks = taskCount == 1
        ? '1 tarea pendiente'
        : '$taskCount tareas pendientes';
    return 'Tienes $events y $tasks. ¿Quieres que te organice la tarde?';
  }

  if (eventCount > 0) {
    return eventCount == 1
        ? 'Tienes 1 evento hoy.'
        : 'Tienes $eventCount eventos hoy.';
  }

  return taskCount == 1
      ? 'Tienes 1 tarea pendiente.'
      : 'Tienes $taskCount tareas pendientes.';
}

/// Texto visible en la tarjeta compacta: última respuesta de Aris o contexto del día.
String homeArisCardDisplayMessage({
  required List<ChatMessageModel> messages,
  required int eventCount,
  required int taskCount,
}) {
  final last = homeLastArisMessageText(messages);
  if (last != kHomeArisDefaultReadyMessage) return last;
  return homeArisDayContextMessage(
    eventCount: eventCount,
    taskCount: taskCount,
  );
}

/// Último texto de Aris en el hilo (sin burbuja pendiente ni placeholder).
String homeLastArisMessageText(List<ChatMessageModel> messages) {
  for (var i = messages.length - 1; i >= 0; i--) {
    final m = messages[i];
    if (!m.isAris || m.awaitingBackend) continue;
    final t = m.text.trim();
    if (t.isEmpty ||
        t == 'Consultando…' ||
        t == ChatService.thinkingMessage) {
      continue;
    }
    return m.text;
  }
  return kHomeArisDefaultReadyMessage;
}

/// Heurística para abrir chat inside si la respuesta es larga o trae `ui_hint`.
bool homeShouldOpenFullChatForResponse({
  required String text,
  String? uiHint,
}) {
  if (uiHint != null && uiHint.trim().isNotEmpty) return true;
  final t = text.trim();
  if (t.length > 280) return true;
  if (t.split(RegExp(r'\r?\n')).length > 3) return true;
  return false;
}
