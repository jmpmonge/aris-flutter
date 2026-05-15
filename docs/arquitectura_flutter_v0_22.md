# Arquitectura Flutter — v0.22 (fase 1)

## Objetivo
Base **mobile-first** centrada en **iOS/App Store**, producto **Aris** y asistente **Clara**, con fronteras claras entre capas antes de introducir integraciones.

## Principios (alineados con `.cursor/rules/`)
- **Sin backend en UI**: datos y servicios falsos hasta la fase de integración.
- **Sin dependencias añadidas** salvo las del template (`cupertino_icons`, `flutter_lints`) y el SDK.
- **Features acotadas**: cada dominio de producto vive bajo `lib/features/<nombre>/`.
- **Compartido mínimo**: solo utilidades transversales en `lib/shared/` y tokens/tema en `lib/theme/`.

## Estructura actual

```
lib/
  main.dart                 # Entrada
  app.dart                  # ArisApp + pantalla bootstrap mínima
  theme/
    app_theme.dart          # ThemeData inicial (Material 3)
  shared/
    widgets/
      app_sizes.dart        # Constantes táctiles (referencia iOS)
    layout/
      breakpoints.dart      # Ancho “narrow” orientativo
    navigation/
      app_routes.dart       # Constantes de ruta (sin router todavía)
  features/
    home/              …_feature_shell.dart
    calendar/          …
    notes/             …
    mail/              …
    profile/           …
    assistant/         …
    settings/          …
assets/                   # Activos estáticos (vacío salvo .gitkeep)
```

## Flujo de arranque
1. `main()` arranca `ArisApp`.
2. `ArisApp` aplica `AppTheme.light()` y fija `home` en la pantalla bootstrap interna.
3. Los `*FeatureShell` **no** participan aún en el árbol; sirven como ancla de módulo para fases 3–4.

## Navegación (estado fase 1)
- `AppRoutes` define **strings** para futuro router (p. ej. `go_router` u otro) sin añadir paquetes ahora.
- Evita dependencias y mantiene el proyecto compilable con el mínimo número de capas.

## Datos y dominio
- No hay capa `data/` ni `domain/` todavía; se introducirán por feature cuando existan flujos reales o mocks con interfaces.
- Regla: ningún acceso a red, calendario nativo, ni proveedores de correo en v0.22 fase UI.

## Pruebas
- `test/widget_test.dart`: smoke test del `AppBar` bootstrap.
- Ampliar tests de widget cuando el shell navegue entre features.

## Evolución prevista
| Fase roadmap | Cambio arquitectónico esperado |
|--------------|--------------------------------|
| 2 Sistema visual | Ampliar `lib/theme/`, posible `design_system/` |
| 3 App shell | `AppShell` + tabs/stack; cablear rutas a `*FeatureShell` o sucesores |
| 4 Pantallas simuladas | `data/` mock + modelos de presentación por feature |
| 6 Integraciones | Implementaciones reales detrás de puertos; iOS permissions |

## Referencias
- Roles y gobernanza: `docs/arquitectura_agentes.md`
- Límites de producto: `docs/roadmap_v0_22.md`
- Notas de versión: `docs/version_0_22_flutter_base.md`
