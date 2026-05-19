import 'dart:async';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../api/api_result.dart';
import '../models/assistant_action_model.dart';
import '../models/assistant_response_model.dart';
import '../models/chat_message_model.dart';
import '../services/assistant_service.dart';
import '../services/chat_service.dart';

/// Contrato de asistente / chat (`POST /message` desde v0.40).
abstract interface class AssistantRepository {
  List<AssistantActionModel> getQuickActions();

  List<ChatMessageModel> getRecentConversation();

  /// Envía texto al servidor FastAPI y actualiza la conversación en pantalla.
  Future<ApiResult<AssistantResponseModel>> sendMessage(String text);

  void sendVoicePendingNotice();
}

/// Implementación estándar: mismo listado demo + chat con backend local.
///
/// `IntentClassifier`, `ChatService.sendLocalMessage` y compañía permanecen
/// para otros flujos o demo; esta ruta usa solo red para la burbuja de respuesta.
final class DefaultAssistantRepository implements AssistantRepository {
  DefaultAssistantRepository(
    this._client, {
    Future<void> Function()? afterSuccessfulPost,
  }) : _afterSuccessfulPost = afterSuccessfulPost;

  final ApiClient _client;
  final Future<void> Function()? _afterSuccessfulPost;

  @override
  List<AssistantActionModel> getQuickActions() {
    return AssistantService.getQuickActions();
  }

  @override
  List<ChatMessageModel> getRecentConversation() {
    return ChatService.getRecentConversation();
  }

  @override
  Future<ApiResult<AssistantResponseModel>> sendMessage(String text) async {
    final merged = text.trim();
    if (merged.isEmpty) {
      return ApiResult.failure(
        ApiException(
          'Escribe algo antes de enviar.',
          code: 'empty_message',
        ),
      );
    }

    ChatService.appendUserOnly(merged);
    final pendingId = ChatService.appendPendingBackendBubble();
    final res = await _client.sendMessage(merged);
    ChatService.removeMessageById(pendingId);

    if (res.isSuccess && res.data != null) {
      try {
        final model = AssistantResponseModel.fromBackendJson(res.data!);
        if (model.text.trim().isEmpty) {
          ChatService.appendOfflineBackendFallback();
          return ApiResult.failure(
            ApiException(
              'El servidor respondió sin texto usable.',
              code: 'bad_response',
            ),
          );
        }
        ChatService.appendArisBackendMessage(
          model.text,
          uiHint: model.uiHint,
        );
        final hook = _afterSuccessfulPost;
        if (hook != null) unawaited(hook());
        return ApiResult.success(model);
      } on Object catch (e) {
        ChatService.appendOfflineBackendFallback();
        return ApiResult.failure(
          ApiException(
            'Respuesta del servidor ilegible.',
            code: 'bad_response',
            cause: e,
          ),
        );
      }
    }

    ChatService.appendOfflineBackendFallback();
    final err = res.error;
    return err != null
        ? ApiResult.failure(err)
        : ApiResult.failure(
            ApiException(
              ChatService.backendOfflineFriendlyReply,
              code: 'unknown',
            ),
          );
  }

  @override
  void sendVoicePendingNotice() {
    ChatService.sendVoicePendingNotice();
  }
}
