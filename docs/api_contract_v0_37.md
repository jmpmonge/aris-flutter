# Contrato API provisional — Aris v0.37

> **Todo lo siguiente es provisional.** No hay backend desplegado, no hay versionado real de API y los cuerpos JSON son orientativos para alinear Flutter con un futuro servicio.

Prefijo documentado en código: `/v1` ([`ApiEndpoints`](../../lib/core/api/api_endpoints.dart)).

## Tabla de endpoints (futuros)

| Método | Endpoint | Uso | Request esperado (ejemplo) | Response esperado (ejemplo) | Estado actual |
|--------|----------|-----|----------------------------|----------------------------|---------------|
| POST | `/v1/assistant/message` | Enviar mensaje del usuario a Aris (vía backend; la IA nunca en el cliente). | `{ "text": "string", "sessionId": "uuid?" }` | `{ "reply": "string", "suggestions": [] }` | **Pendiente** — simulado con [ChatService](../../lib/core/services/chat_service.dart) e intención local. |
| GET | `/v1/tasks` | Listar tareas del usuario. | — | `{ "items": [ { "id", "title", "completed", ... } ] }` | **Pendiente** — mock [TaskService](../../lib/core/services/task_service.dart) + tareas locales [LocalActionService](../../lib/core/services/local_action_service.dart). |
| POST | `/v1/tasks` | Crear tarea. | `{ "title": "string", "description?": "string", "priority?": "low|medium|high" }` | `{ "id": "string", ... }` | **Pendiente** — creación local vía formulario / chat simulado. |
| PATCH | `/v1/tasks/{id}` | Actualizar tarea (p. ej. completar). | `{ "completed": true }` | `{ "id", "completed", ... }` | **Pendiente** — toggle local en tarjetas simuladas. |
| GET | `/v1/notes` | Listar notas. | Query: `?q=` opcional | `{ "items": [...] }` | **Pendiente** — mock [NoteService](../../lib/core/services/note_service.dart). |
| POST | `/v1/notes` | Crear nota. | `{ "title", "body", "category?" }` | `{ "id", ... }` | **Pendiente** — [LocalActionService.createNote](../../lib/core/services/local_action_service.dart). |
| GET | `/v1/events` | Listar eventos (rango TBD). | Query: `from`, `to` | `{ "items": [...] }` | **Pendiente** — mock [CalendarService](../../lib/core/services/calendar_service.dart). |
| POST | `/v1/events` | Crear evento. | `{ "title", "description?", "startsAt?" }` | `{ "id", ... }` | **Pendiente** — [LocalActionService.createEvent](../../lib/core/services/local_action_service.dart). |
| GET | `/v1/mail/summary` | Resumen / hilos para vista Mail. | Query: `folder?` | `{ "threads": [...] }` | **Pendiente** — mock [MailService](../../lib/core/services/mail_service.dart). |
| POST | `/v1/mail/draft` | Borrador o acción de correo asistida. | `{ "subject", "body?" }` | `{ "id", "status" }` | **Pendiente** — [LocalActionService.createMailAction](../../lib/core/services/local_action_service.dart). |
| GET | `/v1/user/profile` | Perfil del usuario. | — | `{ "displayName", "email", ... }` | **Pendiente** — mock [UserService](../../lib/core/services/user_service.dart). |
| PATCH | `/v1/settings/theme` | Persistir preferencia de tema en cuenta (futuro). | `{ "theme": "light|dark|system" }` | `{ "theme": "..." }` | **Pendiente** — hoy solo [ThemeService](../../lib/core/services/theme_service.dart) + `SharedPreferences` local. |

## Notas de seguridad

- **Claves de OpenAI (u otros LLM) solo en backend**, nunca empaquetadas en Flutter.
- Autenticación real (OAuth, sesiones, JWT) quedará fuera de este documento hasta definir proveedor.

## Código relacionado

- [`ApiClient`](../../lib/core/api/api_client.dart) — sin HTTP activo.
- [`ApiResult`](../../lib/core/api/api_result.dart) / [`ApiException`](../../lib/core/api/api_exception.dart) — contrato de error/éxito genérico.
