/// Autor del mensaje en el hilo simulado.
enum ChatMessageSender { aris, user }

/// Mensaje de conversación (solo demo).
class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.sender,
    required this.text,
    this.createdAt,
  });

  final String id;
  final ChatMessageSender sender;
  final String text;
  final DateTime? createdAt;

  bool get isAris => sender == ChatMessageSender.aris;

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender': sender.name,
    'text': text,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      sender: ChatMessageSender.values.byName(json['sender'] as String),
      text: json['text'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
