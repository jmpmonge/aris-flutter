import '../models/chat_message_model.dart';

/// Mapeo tolerante desde filas `/history`: `user_text`, `assistant_text`,
/// `intent_type`, `created_at`, y opcionalmente `ui_hint` en la respuesta del asistente.
abstract final class BackendHistoryMapper {
  static List<ChatMessageModel> toChatMessages(
    List<Map<String, dynamic>> raw,
  ) {
    final out = <ChatMessageModel>[];
    var i = 0;
    for (final row in raw) {
      final userTxt = _asTrimmedString(row['user_text']);
      final assistantTxt = _asTrimmedString(row['assistant_text']);
      final tsRaw = row['created_at'];
      DateTime anchor;
      try {
        if (tsRaw is String && tsRaw.isNotEmpty) {
          anchor =
              DateTime.tryParse(tsRaw) ?? DateTime.now().toUtc().toLocal();
        } else {
          anchor = DateTime.now().toUtc().toLocal();
        }
      } on Object {
        anchor = DateTime.now().toUtc().toLocal();
      }

      if (userTxt.isNotEmpty) {
        final at = anchor;
        out.add(
          ChatMessageModel(
            id: 'bh_${i}_u_${at.microsecondsSinceEpoch}',
            sender: ChatMessageSender.user,
            text: userTxt,
            createdAt: at,
            kind: ChatMessageKind.text,
          ),
        );
      }

      if (assistantTxt.isNotEmpty) {
        final at =
            anchor.add(Duration(milliseconds: (userTxt.isNotEmpty ? 12 : 0)));
        final hintRaw = row['ui_hint'] ?? row['uiHint'];
        final uiHint =
            hintRaw is String && hintRaw.isNotEmpty ? hintRaw.trim() : null;
        out.add(
          ChatMessageModel(
            id: 'bh_${i}_a_${at.microsecondsSinceEpoch}',
            sender: ChatMessageSender.aris,
            text: assistantTxt,
            createdAt: at,
            kind: ChatMessageKind.suggestion,
            backendUiHint: uiHint,
          ),
        );
      }

      i++;
    }
    return out;
  }

  static String _asTrimmedString(Object? v) {
    if (v == null) return '';
    return v.toString().trim();
  }
}
