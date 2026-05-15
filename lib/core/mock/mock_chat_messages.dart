import '../models/chat_message_model.dart';

abstract final class MockChatMessages {
  static List<ChatMessageModel> recentConversation() {
    return const [
      ChatMessageModel(
        id: 'mock_chat_1',
        sender: ChatMessageSender.aris,
        text:
            'He agrupado tus reuniones de la tarde. ¿Quieres que te avise 15 min antes?',
      ),
      ChatMessageModel(
        id: 'mock_chat_2',
        sender: ChatMessageSender.user,
        text: 'Sí, avísame para las 15:15.',
      ),
      ChatMessageModel(
        id: 'mock_chat_3',
        sender: ChatMessageSender.aris,
        text: 'Listo. Es solo una demostración — sin notificaciones reales.',
      ),
    ];
  }
}
