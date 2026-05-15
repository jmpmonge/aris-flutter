# Versión 0.23.0 — Design system Clara / Aris

## Resumen
Se introdujo el **sistema visual base** (tokens + componentes reutilizables) alineado con la regla `03_estilo_visual_clara.md`: tono **premium, cálido y mobile-first**, preparado para evolución hacia App Store sin dependencias nuevas.

## Dependencias
Sin paquetes externos añadidos (solo SDK, `cupertino_icons` y `flutter_lints` como en v0.22).

## Archivos de tema (`lib/theme/`)
| Archivo | Rol |
|---------|-----|
| `app_colors.dart` | Paleta Aris (primario frío sobrio) + Clara (terciario cálido), superficies cálidas, texto y bordes |
| `app_spacing.dart` | Escala 4/8, radios, objetivo táctil ~44 |
| `app_typography.dart` | `TextTheme` claro con jerarquía legible (sistema SF en iOS) |
| `app_theme.dart` | `ThemeData` M3: cards, inputs, `NavigationBar`, FAB |

## Widgets compartidos (`lib/shared/widgets/`)
- `AppCard`, `AppHeader`, `AppSearchBar`, `AppFloatingActionButton`, `AppBottomNavigation`, `SectionTitle`, `EmptyStateCard`
- Modelo de navegación: `AppNavDestination` en `app_bottom_navigation.dart`

## Validación en app
`ArisApp` muestra una **vista previa mínima** (`_DesignSystemPreview`) que combina los componentes anteriores; sigue siendo **mock**, no una pantalla de producto ni shell definitivo (fase 3).

## Comandos
```bash
cd /Users/jose/proyectos/aris_flutter_v0.22
flutter pub get
flutter analyze
flutter test
flutter run -d ios
```

## Próximo hito
**Fase 3 — App shell**: cablear rutas reales, tabs definitivos y safe areas/Clara según roadmap.
