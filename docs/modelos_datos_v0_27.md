# Modelos de cliente — v0.27

Todos viven en `lib/core/models/`. Son **modelos de presentación/cliente**: no reflejan tablas ni DTOs de un backend concreto.

| Archivo | Entidad | Campos principales |
|---------|---------|-------------------|
| `event_model.dart` | `EventModel` | `id`, `start`, `end?`, `title`, `detail` · `homePreviewLine`, `timeHm` |
| `task_model.dart` | `TaskModel` | `id`, `title`, `completed`, `dueDate?` · `copyWith` |
| `note_model.dart` | `NoteModel` | `id`, `title`, `body`, `quickLabel?` · `homePreviewLine` |
| `mail_model.dart` | `MailModel` | `id`, `folderIndex`, `senderName`, `subject`, `preview` |
| `user_model.dart` | `UserModel` | `id`, `displayName`, `emailSimulated`, `avatarInitial?` · `primaryInitial` |
| `user_model.dart` | `ProfileMenuEntryModel` | `iconKey`, `title`, `subtitle` |
| `chat_message_model.dart` | `ChatMessageModel`, `ChatMessageSender` | `id`, `sender`, `text`, `createdAt?` |
| `assistant_action_model.dart` | `AssistantActionModel` | `id`, `title`, `subtitle`, `iconKey` |

## Serialización

Cada modelo expone `toJson()` y `factory fromJson(...)` con claves **genéricas** (`id`, `title`, etc.). Sirven como **contrato interno** hasta que exista esquema de API acordado. Pueden cambiar cuando se conozca el backend.

## Relación con mock

Los valores de ejemplo están en `lib/core/mock/*.dart` y no deben mezclarse con la definición de tipos.
