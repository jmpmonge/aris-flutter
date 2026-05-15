# Versión 0.24.0 — App Shell Aris

## Resumen
Se implementó el **contenedor navegable principal**: cinco pestañas fijas (Inicio, Calendario, Notas, Mail, Perfil), **FAB central flotante** que abre **`AssistantScreen`** y **estado preservado** por pestaña vía `IndexedStack`. Todo el contenido sigue siendo **mock** (sin APIs, calendario o correo reales).

## Qué hay de nuevo
| Elemento | Ubicación |
|----------|-----------|
| Shell de navegación | `lib/shared/navigation/app_navigation_shell.dart` |
| Pantallas por feature | `lib/features/*/presentation/*_screen.dart` |
| Ajustes (stack secundario) | `lib/features/settings/presentation/settings_screen.dart` |
| Entrada de la app | `lib/app.dart` → `home: AppNavigationShell()` |

## Dependencias
Ninguna nueva en `pubspec.yaml` (solo SDK y dependencias ya existentes).

## Límites
- Sin backend, OpenAI, auth, IMAP ni eventos reales.
- Sin formularios complejos ni lógica de negocio persistente.
- `HomePreviewScreen` (v0.23) **ya no es la entrada**; puede conservarse como referencia o eliminarse en limpieza futura.

## Comprobación
```bash
flutter pub get
flutter analyze
flutter test
flutter run -d ios
```

## Paquete
`pubspec.yaml`: **0.24.0+1**

## Siguiente paso recomendado
**Fase 4 — Pantallas simuladas en profundidad:** estados vacío/carga/error, modelos de presentación por feature y sustitución gradual de strings hardcodeados por repositorios mock con interfaces claras.

## Detalle técnico de navegación
Ver `docs/navigation_shell_v0_24.md`.
