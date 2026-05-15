# Arquitectura Flutter — ARIS (base v0.22 → design v0.23)

## Objetivo
Base **mobile-first** centrada en **iOS/App Store**, producto **Aris** y asistente **Clara**, con fronteras claras entre capas antes de introducir integraciones.

## Principios (alineados con `.cursor/rules/`)
- **Sin backend en UI**: datos y servicios falsos hasta la fase de integración.
- **Sin dependencias añadidas** salvo las del template (`cupertino_icons`, `flutter_lints`) y el SDK.
- **Features acotadas**: cada dominio de producto vive bajo `lib/features/<nombre>/`.
- **Compartido mínimo**: utilidades transversales en `lib/shared/` y **tokens + tema** en `lib/theme/`.

## Estructura actual

```
lib/
  main.dart                 # Entrada
  app.dart                  # ArisApp + vista previa mínima del design system (mock)
  theme/
    app_colors.dart         # Tokens de color Clara / Aris
    app_spacing.dart        # Escala, radios, touch target
    app_typography.dart     # TextTheme claro
    app_theme.dart          # ThemeData M3 + temas de componentes
  shared/
    widgets/
      app_card.dart
      app_header.dart
      app_search_bar.dart
      app_floating_action_button.dart
      app_bottom_navigation.dart
      section_title.dart
      empty_state_card.dart
    layout/
      breakpoints.dart
    navigation/
      app_routes.dart
  features/
    home/              …_feature_shell.dart
    calendar/          …
    notes/             …
    mail/              …
    profile/           …
    assistant/         …
    settings/          …
assets/
```

## Flujo de arranque
1. `main()` arranca `ArisApp`.
2. `ArisApp` aplica `AppTheme.light()` y muestra `_DesignSystemPreview`: lista scroll con componentes para **validar tokens** (no es shell de producto).
3. Los `*FeatureShell` siguen sin estar cableados al flujo principal; son anclas de módulo para fases 3–4.

## Navegación
- La barra inferior en la vista previa es **solo demostración** de `AppBottomNavigation`.
- `AppRoutes` mantiene **strings** para un router futuro sin paquetes extra.

## Datos y dominio
- No hay capa `data/` ni `domain/` todavía; se introducirán por feature cuando existan flujos reales o mocks con interfaces.
- Regla: ningún acceso a red, calendario nativo, ni proveedores de correo en fase UI.

## Pruebas
- `test/widget_test.dart`: smoke test de la vista previa del design system (`Key('design_system_preview')`).
- Ampliar tests cuando el app shell navegue entre features reales.

## Evolución prevista
| Fase roadmap | Cambio arquitectónico esperado |
|--------------|--------------------------------|
| 3 App shell | `AppShell` + tabs/stack; rutas a pantallas por feature |
| 4 Pantallas simuladas | `data/` mock + modelos de presentación por feature |
| 6 Integraciones | Implementaciones reales detrás de puertos; permisos iOS |

## Referencias
- Design system: `docs/design_system_v0_23.md`, `docs/version_0_23_design_system.md`
- Roles: `docs/arquitectura_agentes.md`
- Roadmap: `docs/roadmap_v0_22.md`
- Base inicial: `docs/version_0_22_flutter_base.md`
