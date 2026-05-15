# Aris v0.27 — Modelos locales y servicios mock

## Objetivo

Centralizar datos de demostración en **`lib/core/models/`**, **`lib/core/mock/`** y **`lib/core/services/`**, sin asumir contrato de backend ni proveedores externos. Producto **Aris**; sin «Clara».

## Qué se añadió

- **Modelos** con `toJson` / `fromJson` orientativos (futura serialización; no ligados a una API concreta).
- **Datos mock** en archivos dedicados bajo `lib/core/mock/`.
- **Servicios mock** (`abstract final class` + métodos `static`) que leen únicamente esos datos.
- **Mapeo de iconos** por clave estable en `lib/core/icon_from_key.dart` (evita serializar `IconData` en modelos).

## Pantallas migradas

Las pantallas de features consumen servicios en lugar de listas embebidas:

| Pantalla | Servicios |
|----------|-----------|
| `HomeScreen` | `UserService`, `CalendarService`, `TaskService`, `NoteService`, `ChatService` |
| `CalendarScreen` + vistas | `CalendarService` (vía widgets en `calendar_body_views.dart`) |
| `NotesScreen` | `NoteService` |
| `TasksScreen` | `TaskService` |
| `MailScreen` | `MailService` |
| `ProfileScreen` | `UserService` |
| `AssistantScreen` | `AssistantService` |

## Límites de la versión

- Sin red, sin OAuth, sin calendario/correo del sistema, sin OpenAI.
- Sin gestión de estado global (Riverpod, Bloc, etc.): llamadas directas a servicios mock.
- Los datos siguen siendo **ficticios** y **en memoria**.

## Limpieza

Se eliminaron los ficheros `*_mock_content.dart` bajo `lib/features/*/data/` (datos movidos a `lib/core/mock/`).

## Riesgos pendientes

- Cuando exista API real, habrá que **sustituir** implementaciones mock por clientes HTTP y mapear DTO ↔ modelos (los nombres/campos pueden cambiar).
- `iconFromKey` debe mantenerse alineado con las claves guardadas en modelos/mock.

## Siguiente paso recomendado

- Definir **contrato provisional** de API (OpenAPI o similar) y capa `data` con adaptadores; mantener `domain`/`core` modelos si el equipo lo prioriza.
- Tests unitarios de `fromJson`/`toJson` y de servicios mock (respuestas estables).

## Verificación

- `flutter analyze` sin issues.
- `flutter test` OK.

Versión: **0.27.0+1** (`pubspec.yaml`, `AppMeta`).
