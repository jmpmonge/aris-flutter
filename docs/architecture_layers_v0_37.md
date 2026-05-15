# Capas de arquitectura — Aris v0.37

## Vista en pirámide (objetivo)

```
UI / Pantallas / Widgets
        ↓
   Repositories (contrato)
        ↓
 Servicios locales / mock  —  (futuro) ApiClient + backend
        ↓
   Backend / API / BD / IA
```

## Estado en v0.37

| Capa | Rol hoy |
|------|---------|
| **UI** | `lib/features/*`, `lib/shared/widgets/*` — sin cambios visuales. |
| **Repositories** | `lib/core/repositories/*` — interfaces + `Local*` que **delegan** en servicios existentes. Punto único para sustituir implementación cuando exista API. |
| **Services** | `lib/core/services/*` — mocks, `SharedPreferences`, chat local, etc. |
| **API** | `lib/core/api/*` — tipos y `ApiClient` **sin red**. |

## Reglas de transición

1. Las pantallas **no** deberían importar `ApiClient` directamente cuando llegue el backend; deben usar repositorios (o casos de uso que estos encapsulen).
2. **OpenAI y cualquier clave secreta** solo en servidor; Flutter habla con **tu** API.
3. Los endpoints documentados son **provisionales**; el código de rutas vive en [`ApiEndpoints`](../lib/core/api/api_endpoints.dart). Ver también [api_contract_v0_37.md](api_contract_v0_37.md).

4. `Repositories` en [`repositories.dart`](../lib/core/repositories/repositories.dart) centraliza instancias locales; más adelante se puede reemplazar por inyección (get_it, Riverpod, etc.) sin renombrar interfaces.

## Integración parcial ya hecha (v0.37)

- [`ArisApp`](../lib/app.dart) escucha [`Repositories.settings.themeListenable`](../lib/core/repositories/settings_repository.dart).
- [`AppNavigationShell`](../lib/shared/navigation/app_navigation_shell.dart) envía mensajes vía [`Repositories.assistant`](../lib/core/repositories/assistant_repository.dart).
- [`AssistantScreen`](../lib/features/assistant/presentation/assistant_screen.dart) obtiene acciones rápidas vía el mismo repositorio.
- [`SettingsScreen`](../lib/features/settings/presentation/settings_screen.dart) actualiza tema vía [`Repositories.settings`](../lib/core/repositories/settings_repository.dart).

El resto de pantallas siguen llamando a servicios **directamente**; la migración incremental está permitida sin refactor masivo.

## Riesgos

- Duplicidad temporal: una parte del código usa repositorios y otra servicios; conviene converger hacia repositorios por feature.
- Si se añade HTTP en `ApiClient`, revisar timeouts, cancelación y modelo de errores unificado con `ApiResult`.
