import '../models/assistant_action_model.dart';
import '../models/chat_message_model.dart';
import '../services/assistant_service.dart';
import '../services/chat_service.dart';

/// Contrato de asistente / chat. Implementación actual: [LocalAssistantRepository].
abstract interface class AssistantRepository {
  List<AssistantActionModel> getQuickActions();

  List<ChatMessageModel> getRecentConversation();

  void sendUserMessage(String text);

  void sendVoicePendingNotice();
}

/// Puente local hasta [ApiEndpoints.assistantMessage] u otro canal real.
final class LocalAssistantRepository implements AssistantRepository {
  @override
  List<AssistantActionModel> getQuickActions() {
    return AssistantService.getQuickActions();
  }

  @override
  List<ChatMessageModel> getRecentConversation() {
    return ChatService.getRecentConversation();
  }

  @override
  void sendUserMessage(String text) {
    ChatService.sendLocalMessage(text);
  }

  @override
  void sendVoicePendingNotice() {
    ChatService.sendVoicePendingNotice();
  }
}
