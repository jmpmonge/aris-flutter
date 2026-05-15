# Aris v0.37 — Contrato API provisional y repositorios

## Introducción

Versión **0.37.0+1** introduce una **capa API abstracta** (`lib/core/api/`) y **repositorios** (`lib/core/repositories/`) como puente hacia un backend futuro, **sin HTTP real**, sin OpenAI en cliente y sin nuevas dependencias de red.

## Archivos nuevos

### `lib/core/api/`

| Archivo | Propósito |
|---------|-----------|
| `api_client.dart` | Cliente preparado; `get`/`post`/`patch` devuelven fallo `no_backend`. |
| `api_endpoints.dart` | Constantes `/v1/...` **provisionales**. |
| `api_result.dart` | Patrón éxito / error genérico (`ApiResult<T>`). |
| `api_exception.dart` | Excepción de dominio API (`ApiException`). |

### `lib/core/repositories/`

| Archivo | Contrato |
|---------|----------|
| `assistant_repository.dart` | Chat rápido / mensajes locales. |
| `task_repository.dart` | Tareas mock + acciones locales tipo tarea. |
| `note_repository.dart` | Notas mock + acciones locales tipo nota. |
| `calendar_repository.dart` | Eventos mock + acciones locales tipo evento. |
| `mail_repository.dart` | Vista mail mock + acciones locales tipo correo. |
| `user_repository.dart` | Usuario / textos de home de perfil. |
| `settings_repository.dart` | Tema (delega en `ThemeService`). |
| `repositories.dart` | `Repositories.*` instancias `Local*` por defecto. |

### Documentación

- [api_contract_v0_37.md](api_contract_v0_37.md) — tabla Método / Endpoint / Estado.
- [architecture_layers_v0_37.md](architecture_layers_v0_37.md) — separación de capas.

## Archivos modificados (integración ligera)

- `lib/app.dart` — escucha `Repositories.settings.themeListenable`.
- `lib/shared/navigation/app_navigation_shell.dart` — envío de mensaje / voz vía `Repositories.assistant`.
- `lib/features/assistant/presentation/assistant_screen.dart` — acciones rápidas vía repositorio.
- `lib/features/settings/presentation/settings_screen.dart` — tema vía `Repositories.settings`.
- `test/repositories_smoke_test.dart` — pruebas de humo sobre repositorios y `ApiClient.provisional()`.

## Qué **no** está conectado

- Ningún host HTTP, Firebase, Supabase, FastAPI/Node reales.
- OpenAI, Google Calendar, Gmail, Apple Calendar, RevenueCat, login real.
- Base de datos remota.

## Endpoints

Todos los path bajo `ApiEndpoints` son **provisionales**; el producto puede cambiar prefijo, nombres y payloads. Ver tabla en [api_contract_v0_37.md](api_contract_v0_37.md).

## Riesgos

- **Doble vía** temporal: parte de la UI sigue llamando a `*Service` directamente; hay que migrar por features para no duplicar lógica.
- Al implementar red, definír **un** mapeo HTTP → modelos y errores; evitar que las pantallas acoplen a status codes.

## Siguiente paso recomendado

1. Elegir stack backend y versionar OpenAPI (o similar) alineado con esta tabla.
2. Implementar `ApiClient` real y una primera `RemoteTaskRepository` (o equivalente) detrás de la misma interfaz.
3. Migrar pantallas restantes de servicios a repositorios de forma incremental.

## Conclusión

Aris mantiene el mismo comportamiento visual y local, pero con **contrato documentado** y **costura** lista para sustituir mocks por API cuando exista servidor propio.
