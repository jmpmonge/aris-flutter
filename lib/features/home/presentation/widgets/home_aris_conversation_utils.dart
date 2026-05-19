import '../../../../core/models/chat_message_model.dart';

/// Mensaje inicial si aún no hay respuesta de Aris en Home (v0.48.43).
const String kHomeArisDefaultReadyMessage =
    'Estoy listo para ayudarte con tu día.';

/// Instrucciones desde Home antes de abrir chat inside.
const int kHomeArisInstructionsBeforeInsideChat = 3;

/// Último texto de Aris en el hilo (sin burbuja pendiente ni placeholder).
String homeLastArisMessageText(List<ChatMessageModel> messages) {
  for (var i = messages.length - 1; i >= 0; i--) {
    final m = messages[i];
    if (!m.isAris || m.awaitingBackend) continue;
    final t = m.text.trim();
    if (t.isEmpty || t == 'Consultando…') continue;
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
