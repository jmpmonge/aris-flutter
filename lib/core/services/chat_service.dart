import 'package:flutter/foundation.dart';

import '../mock/mock_chat_messages.dart';
import '../models/chat_message_model.dart';
import '../models/intent_model.dart';
import 'intent_classifier_service.dart';

/// Servicio mock de chat con **memoria local** en la sesión (sin red).
abstract final class ChatService {
  static final List<ChatMessageModel> _messages = [];

  static bool _initialized = false;

  /// Notifica cambios en la conversación local (p. ej. para scroll en Home).
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static int get messageCount => _messages.length;

  static void _ensureInitialized() {
    if (_initialized) return;
    _messages.addAll(MockChatMessages.recentConversation());
    _initialized = true;
  }

  /// Copia actual de la conversación (incluye envíos locales de la sesión).
  static List<ChatMessageModel> getRecentConversation() {
    _ensureInitialized();
    return List<ChatMessageModel>.unmodifiable(_messages);
  }

  /// Añade el mensaje del usuario y una respuesta simulada de Aris según intención local.
  static void sendLocalMessage(String rawText) {
    _ensureInitialized();
    final text = rawText.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    _messages.add(
      ChatMessageModel(
        id: 'local_${now.microsecondsSinceEpoch}_user',
        sender: ChatMessageSender.user,
        text: text,
        createdAt: now,
        kind: ChatMessageKind.text,
      ),
    );

    final intent = IntentClassifierService.classify(text);
    final reply = _replyForIntent(intent);

    _messages.add(
      ChatMessageModel(
        id: 'local_${DateTime.now().microsecondsSinceEpoch}_aris',
        sender: ChatMessageSender.aris,
        text: reply,
        createdAt: DateTime.now(),
        kind: ChatMessageKind.suggestion,
        detectedIntent:
            intent.type == IntentType.unknown ? null : intent,
      ),
    );
    revision.value++;
  }

  /// Respuesta simulada en función de la clasificación local (no es IA).
  static String generateMockArisReply(String userText) {
    return _replyForIntent(IntentClassifierService.classify(userText));
  }

  static String _replyForIntent(IntentModel intent) {
    return switch (intent.type) {
      IntentType.task =>
        'Parece una tarea. De momento la dejo detectada como tarea simulada.',
      IntentType.note =>
        'Parece una nota. La he identificado como nota local simulada.',
      IntentType.event =>
        'Parece un evento. Más adelante podré llevarlo al calendario.',
      IntentType.mail =>
        'Parece relacionado con correo. Cuando activemos integración, podré ayudarte a responder o resumir.',
      IntentType.general =>
        'He recibido tu mensaje. Puedo ayudarte a convertirlo en tarea, nota o evento.',
      IntentType.unknown => 'He registrado tu mensaje.',
    };
  }

  /// Mensaje informativo por micrófono (sin grabación ni permisos).
  static void sendVoicePendingNotice() {
    _ensureInitialized();
    _messages.add(
      ChatMessageModel(
        id: 'local_voice_${DateTime.now().microsecondsSinceEpoch}',
        sender: ChatMessageSender.aris,
        text: 'Función de voz pendiente de activar.',
        createdAt: DateTime.now(),
        kind: ChatMessageKind.suggestion,
      ),
    );
    revision.value++;
  }
}
