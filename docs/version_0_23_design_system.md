# Versión 0.23.x — Design System Aris

## Alcance de esta entrega
- **Tema global** claro y oscuro (`AppTheme.light()` / `AppTheme.dark()`, `ThemeMode.system`).
- **Tokens** en `lib/theme/` (`app_colors`, `app_spacing`, `app_typography`, `app_theme`).
- **Componentes** reutilizables en `lib/shared/widgets/` y navegación en `lib/shared/navigation/`.
- **Layout** `AppScaffold` en `lib/shared/layout/`.
- **Preview no producto:** `lib/features/home/presentation/home_preview_screen.dart` solo para validar UI (saludo “Hola, José”, tres tarjetas mock, barra inferior, FAB circular).

## Límites (sin cambios vs. reglas del repo)
- Sin backend, APIs, OpenAI, calendario real, correo real ni autenticación.
- Sin dependencias nuevas en `pubspec.yaml` (solo SDK + plantilla existente).

## Archivos clave
| Área | Ruta |
|------|------|
| Colores + schemes | `lib/theme/app_colors.dart` |
| Espaciado + elevación tarjetas | `lib/theme/app_spacing.dart` |
| Tipografía | `lib/theme/app_typography.dart` |
| ThemeData | `lib/theme/app_theme.dart` |
| Navegación inferior | `lib/shared/navigation/app_bottom_navigation.dart` |
| Scaffold base | `lib/shared/layout/app_scaffold.dart` |
| Preview visual | `lib/features/home/presentation/home_preview_screen.dart` |
| Entrada app | `lib/app.dart` (`MaterialApp` + temas) |

## Comandos
```bash
flutter pub get
flutter analyze
flutter test
flutter run -d ios
```

Prueba **modo oscuro**: ajusta el simulador/dispositivo a apariencia oscura o fuerza `themeMode: ThemeMode.dark` temporalmente.

## Versión del paquete
`pubspec.yaml`: **0.23.1+1** (iteración sobre el design system v0.23).

## Siguiente paso recomendado
**Fase App shell:** extraer la barra inferior a un contenedor con rutas reales, conectar destinos a módulos bajo `lib/features/*` y eliminar duplicación entre preview y shell definitivo. Mantener `HomePreviewScreen` como referencia de QA visual hasta integrar navegación final.

## Referencia detallada
Ver `docs/design_system_v0_23.md`.
