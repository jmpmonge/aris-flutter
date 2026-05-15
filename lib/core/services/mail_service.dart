import '../mock/mock_mails.dart';
import '../models/mail_model.dart';

abstract final class MailService {
  static List<String> getFolderLabels() => MockMails.folderLabels.toList();

  static List<MailModel> getInboxPreview({int? folderIndex}) {
    final all = MockMails.all();
    if (folderIndex == null) return all;
    return all.where((m) => m.folderIndex == folderIndex).toList();
  }
}
