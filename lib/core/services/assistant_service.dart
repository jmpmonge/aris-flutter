import '../mock/mock_assistant_actions.dart';
import '../models/assistant_action_model.dart';

abstract final class AssistantService {
  static List<AssistantActionModel> getQuickActions() {
    return List<AssistantActionModel>.unmodifiable(MockAssistantActions.list);
  }
}
