# Chat local simulado — v0.28

## Modelo

`ChatMessageModel` (`lib/core/models/chat_message_model.dart`):

| Campo | Tipo | Notas |
|-------|------|--------|
| `id` | `String` | Incluye prefijos `local_` / `mock_` en demo |
| `sender` | `ChatMessageSender` | `aris` · `user` |
| `text` | `String` | Contenido visible en burbuja |
| `createdAt` | `DateTime?` | Relleno en mensajes locales |
| `kind` | `ChatMessageKind` | `text` (defecto), `suggestion`, `action` — solo metadato de presentación |

## Servicio

`ChatService` (`lib/core/services/chat_service.dart`):

- Inicializa la conversación con datos de `MockChatMessages.recentConversation()`.
- `sendLocalMessage`: usuario + Aris (`generateMockArisReply`).
- Respuestas de ejemplo (rotación por hash del texto entrante):  
  - «He registrado tu mensaje.»  
  - «Puedo convertirlo en tarea, nota o evento cuando actives las integraciones.»  
  - «De momento lo dejo en la conversación local.»
- `sendVoicePendingNotice`: una burbuja Aris sobre voz no disponible.
- `revision`: notificación para UI (scroll + repintado).

## No incluido (explícito)

- OpenAI u otros LLM.  
- Endpoints HTTP.  
- Calendario / correo reales.  
- Autenticación.  
- Permiso `microphone` ni `speech`.

## Integración UI

- **Inicio**: bloque RECIENTE + barra inferior deben mostrar la misma fuente (`getRecentConversation`).  
- **Shell**: envía texto y micrófono al servicio; no muestra SnackBar de “caracteres enviados” (sustituido por conversación).

## Referencia

Véase también [version_0_28_chat_local.md](./version_0_28_chat_local.md).
