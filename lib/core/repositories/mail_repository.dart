import '../models/local_action_model.dart';
import '../models/mail_model.dart';
import '../services/local_action_service.dart';
import '../services/mail_service.dart';

/// Contrato de correo (vista mock + acciones locales). Implementación: [LocalMailRepository].
abstract interface class MailRepository {
  List<String> getFolderLabels();

  List<MailModel> getInboxPreview({int? folderIndex});

  List<LocalActionModel> getLocalMailActions();

  LocalActionModel createLocalMailAction({
    required String title,
    String? description,
  });

  void toggleLocalMailCompleted(String id);
}

final class LocalMailRepository implements MailRepository {
  @override
  List<String> getFolderLabels() => MailService.getFolderLabels();

  @override
  List<MailModel> getInboxPreview({int? folderIndex}) {
    return MailService.getInboxPreview(folderIndex: folderIndex);
  }

  @override
  List<LocalActionModel> getLocalMailActions() {
    return LocalActionService.getActionsByType(LocalActionType.mail);
  }

  @override
  LocalActionModel createLocalMailAction({
    required String title,
    String? description,
  }) {
    return LocalActionService.createMailAction(
      title: title,
      description: description,
    );
  }

  @override
  void toggleLocalMailCompleted(String id) {
    LocalActionService.toggleActionCompleted(id);
  }
}
