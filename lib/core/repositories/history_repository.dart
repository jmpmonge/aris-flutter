import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../models/backend_history_mapper.dart';
import '../models/chat_message_model.dart';
import '../services/chat_service.dart';

abstract interface class HistoryRepository {
  Future<bool> refreshFromBackend();

  ValueNotifier<int> get revision;

  /// Combinación de historial remoto + cola local posterior al ancla de sync.
  List<ChatMessageModel> conversationForHome();
}

final class HybridHistoryRepository implements HistoryRepository {
  HybridHistoryRepository(this._client);

  final ApiClient _client;

  @override
  final ValueNotifier<int> revision = ValueNotifier<int>(0);

  bool _historyFromBackendOk = false;
  List<ChatMessageModel> _head = const [];
  int _overlayIndex = 0;

  @override
  Future<bool> refreshFromBackend() async {
    _overlayIndex = ChatService.messageCount;
    final res = await _client.getHistory();
    if (!res.isSuccess || res.data == null) {
      _historyFromBackendOk = false;
      _head = const [];
      revision.value++;
      return false;
    }
    _head = BackendHistoryMapper.toChatMessages(res.data!);
    _historyFromBackendOk = true;
    revision.value++;
    return true;
  }

  @override
  List<ChatMessageModel> conversationForHome() {
    final local = ChatService.getRecentConversation();
    if (!_historyFromBackendOk) return local;

    final start = math.min(_overlayIndex, local.length);
    final tail = List<ChatMessageModel>.from(local.sublist(start));
    return <ChatMessageModel>[..._head, ...tail];
  }
}
