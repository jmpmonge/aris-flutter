# Aris v0.35 — Modo claro / oscuro configurable

## Resumen

El usuario puede elegir **Claro**, **Oscuro** o **Sistema** desde **Ajustes**. La preferencia se guarda en **`SharedPreferences`** y se carga al arranque; el cambio aplica al instante vía `ThemeService` + `MaterialApp.themeMode`.

## Archivos nuevos o clave

| Ruta | Rol |
|------|-----|
| `lib/core/models/app_theme_mode.dart` | `AppThemePreference` + etiquetas en español. |
| `lib/core/services/theme_service.dart` | `ValueNotifier<ThemeMode>`, `initialize()`, `setThemeMode()`. |
| `lib/app.dart` | `StatefulWidget` escucha el notificador y repinta `MaterialApp`. |
| `lib/main.dart` | `await ThemeService.initialize()` antes de `LocalActionService`. |
| `lib/features/settings/presentation/settings_screen.dart` | Segmented control de apariencia en tarjeta. |
| `lib/theme/app_theme.dart` | Getters `lightTheme` / `darkTheme` para `MaterialApp`. |
| `lib/theme/app_colors.dart` | Superficies oscuras azul‑gris refinadas. |

## Flujo

1. `ThemeService.initialize()` lee `aris_theme_mode_v1` (`light` | `dark` | `system`).
2. `ArisApp` usa `themeMode: ThemeService.themeMode.value`.
3. Al cambiar en Ajustes, `setThemeMode` actualiza memoria y persiste.

## Resultado

- **Sin backend** ni APIs.
- **Sin nuevas dependencias** (reutiliza `shared_preferences`).
- Modo oscuro **real** (tokens dedicados), no simple inversión.

## Limitaciones

- No hay selector duplicado en Perfil; el acceso sigue siendo **Perfil → Preferencias → Ajustes**.

## Siguiente paso sugerido

Sincronizar con `MediaQuery.platformBrightness` solo para analytics locales opcionales; accesibilidad (`highContrast` / text scale) en v0.36.
