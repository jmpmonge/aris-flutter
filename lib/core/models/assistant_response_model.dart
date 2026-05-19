/// Respuesta de `POST /message` (`AssistantResponse` en FastAPI: `text`, `type`,
/// `ui_hint`, `created_at`).
final class AssistantResponseModel {
  const AssistantResponseModel({
    required this.text,
    this.type,
    this.uiHint,
    this.createdAt,
  });

  final String text;
  /// P. ej. `"assistant"`.
  final String? type;
  /// JSON `ui_hint` → propiedad Dart `uiHint`.
  final String? uiHint;
  /// JSON `created_at` (ISO 8601).
  final DateTime? createdAt;

  /// Parse desde JSON emitido por FastAPI/Pydantic (`ui_hint`, `created_at`).
  factory AssistantResponseModel.fromBackendJson(Map<String, dynamic> json) {
    final rawText = json['text'];
    final text =
        rawText is String ? rawText : rawText?.toString() ?? '';

    DateTime? createdAt;
    final created = json['created_at'];
    if (created is String && created.isNotEmpty) {
      createdAt = DateTime.tryParse(created);
    }

    final hintRaw = json['ui_hint'] ?? json['uiHint'];
    final String? uiHint = hintRaw is String ? hintRaw : null;

    return AssistantResponseModel(
      text: text,
      type: json['type'] as String?,
      uiHint: uiHint,
      createdAt: createdAt,
    );
  }
}
