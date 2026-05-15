/// Hilo de correo simulado (sin buzón real).
class MailModel {
  const MailModel({
    required this.id,
    required this.folderIndex,
    required this.senderName,
    required this.subject,
    required this.preview,
  });

  final String id;
  final int folderIndex;
  final String senderName;
  final String subject;
  final String preview;

  Map<String, dynamic> toJson() => {
    'id': id,
    'folderIndex': folderIndex,
    'senderName': senderName,
    'subject': subject,
    'preview': preview,
  };

  factory MailModel.fromJson(Map<String, dynamic> json) {
    return MailModel(
      id: json['id'] as String,
      folderIndex: json['folderIndex'] as int,
      senderName: json['senderName'] as String,
      subject: json['subject'] as String,
      preview: json['preview'] as String,
    );
  }
}
