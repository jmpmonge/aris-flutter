import 'package:flutter/foundation.dart';

/// Autor del mensaje en el hilo simulado.
enum ChatMessageSender { aris, user }

/// Tipo superficial de mensaje (solo presentación / futura serialización).
enum ChatMessageKind { text, suggestion, action }

/// Mensaje de conversación (solo demo; sin backend).
@immutable
class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.sender,
    required this.text,
    this.createdAt,
    this.kind = ChatMessageKind.text,
  });

  final String id;
  final ChatMessageSender sender;
  final String text;
  final DateTime? createdAt;
  final ChatMessageKind kind;

  bool get isAris => sender == ChatMessageSender.aris;

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender': sender.name,
    'text': text,
    'kind': kind.name,
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
      kind: json['kind'] != null
          ? ChatMessageKind.values.byName(json['kind'] as String)
          : ChatMessageKind.text,
    );
  }
}
