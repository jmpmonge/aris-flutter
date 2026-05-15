# Arquitectura Flutter — ARIS (hasta app shell v0.24)

## Objetivo
Base **mobile-first** (iOS/App Store), producto **Aris**, con capas claras y **solo mocks** hasta integración.

## Principios
- Sin backend en UI; sin dependencias nuevas sin justificar.
- Features en `lib/features/<módulo>/presentation/` (+ futuro `data` / `domain`).
- Tema y piezas comunes en `lib/theme/` y `lib/shared/`.

## Estructura relevante

```
lib/
  app.dart                          # MaterialApp → AppNavigationShell
  shared/
    navigation/
      app_navigation_shell.dart       # 5 tabs + FAB asistente
      app_bottom_navigation.dart
      app_routes.dart
    layout/
      app_scaffold.dart
      breakpoints.dart
    widgets/                          # Design system v0.23
  features/
    home/presentation/
      home_screen.dart
      home_preview_screen.dart        # Legado v0.23, no usado como home
    calendar/presentation/calendar_screen.dart
    notes/presentation/notes_screen.dart
    mail/presentation/mail_screen.dart
    profile/presentation/profile_screen.dart
    assistant/presentation/assistant_screen.dart
    settings/presentation/settings_screen.dart
  theme/
```

## Flujo de arranque
1. `ArisApp` aplica temas claro/oscuro.
2. **`AppNavigationShell`** es el `home`: gestiona índice de pestaña y abre **`AssistantScreen`** con `Navigator`.
3. **Ajustes** se alcanza desde Perfil (ruta empilada).

## Pruebas
- `test/widget_test.dart`: recorre pestañas mediante labels y comprueba `Key('tab_*')`.

## Referencias
- `docs/navigation_shell_v0_24.md`, `docs/version_0_24_app_shell.md`
- `docs/design_system_v0_23.md`
- `docs/roadmap_v0_22.md`
