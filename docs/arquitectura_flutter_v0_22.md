# Arquitectura Flutter — ARIS (base + design system v0.23)

## Objetivo
Base **mobile-first** centrada en **iOS/App Store**, producto **Aris** y asistente **Clara**, con fronteras claras entre capas antes de introducir integraciones.

## Principios (alineados con `.cursor/rules/`)
- **Sin backend en UI** hasta fase de integración.
- **Sin dependencias nuevas** salvo justificación explícita (actualmente: SDK + `cupertino_icons` + `flutter_lints`).
- **Features** bajo `lib/features/<nombre>/` (presentación mock hasta fase 4).
- **Tokens y componentes** en `lib/theme/` y `lib/shared/`.

## Estructura actual

```
lib/
  main.dart
  app.dart                         # MaterialApp: tema claro/oscuro + HomePreviewScreen
  theme/
    app_colors.dart
    app_spacing.dart
    app_typography.dart
    app_theme.dart
  shared/
    widgets/                       # AppCard, AppHeader, AppSearchBar, AppFAB, …
    layout/
      breakpoints.dart
      app_scaffold.dart
    navigation/
      app_routes.dart
      app_bottom_navigation.dart
  features/
    home/presentation/
      home_preview_screen.dart       # Solo validación visual (no home final)
    … otros módulos (shells)
assets/
```

## Flujo de arranque
1. `ArisApp` aplica `AppTheme.light()` / `dark()` y `ThemeMode.system`.
2. La pantalla inicial es **`HomePreviewScreen`**: muestra el design system con datos simulados.
3. Los `*FeatureShell` restantes siguen como anclas de carpeta para fases posteriores.

## Navegación
- `AppBottomNavigation` modela la barra inferior; la integración con rutas reales es **pendiente del app shell**.
- `AppRoutes` conserva constantes de ruta sin paquete router.

## Pruebas
- `test/widget_test.dart` comprueba la preview (`Key('home_preview_screen')`) y textos mock clave.

## Referencias
- `docs/design_system_v0_23.md`, `docs/version_0_23_design_system.md`
- `docs/arquitectura_agentes.md`, `docs/roadmap_v0_22.md`
