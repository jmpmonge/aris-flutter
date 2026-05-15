import '../mock/mock_chat_messages.dart';
import '../models/chat_message_model.dart';

abstract final class ChatService {
  static List<ChatMessageModel> getRecentConversation() {
    return MockChatMessages.recentConversation();
  }
}
