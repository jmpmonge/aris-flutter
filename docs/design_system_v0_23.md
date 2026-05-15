# Design System Aris — v0.23

## Intención visual
App **mobile-first**, sensación de **asistente personal** (cercana, ordenada), **no panel corporativo frío**:
- Lienzo **crema / blanco cálido** en claro; superficies oscuras **con matices cálidos** en dark.
- **Azul profundo** como primario; **violeta suave** como secundario (contenedores, acentos secundarios).
- **Grises cálidos** para texto y bordes.
- **Tarjetas muy redondeadas**, **sombras suaves**, barra inferior **limpia** (sin elevación fuerte), **FAB circular** en primario.

Todo el color de producto debe fluir desde **`ColorScheme`** y tokens en `app_colors.dart`, no desde hex sueltos en pantallas.

## Modo claro y oscuro
- `AppColors.lightScheme` / `AppColors.darkScheme`: dos esquemas M3 coherentes (misma familia cromática, distinto contraste).
- `ArisApp` usa `theme`, `darkTheme` y `themeMode: ThemeMode.system` para respetar el sistema (requisito App Store / UX iOS).

### Paleta resumida (claro)
| Rol | Uso |
|-----|-----|
| `primaryDeep` (#1B3554) | Marca, FAB, ítems seleccionados en nav |
| `violetSoft` / `violetContainer` | Secundario, indicador de nav, chips suaves |
| `canvasLight` | Fondo de `Scaffold` (crema) |
| `surfaceLight` | Tarjetas y bloques elevados |
| `textPrimaryLight` / secundario / terciario | Jerarquía de texto |

### Oscuro
Superficies `#141210`–`#2E2B27`, texto `#F2EDE6`, primario aclarado para contraste (`#9BB4DA`), secundario en violeta pastel (`#CDBFE8`).

## Tokens de layout (`app_spacing.dart`)
- Escala **4 / 8**: `xxs` … `xxl`.
- Radios: **10 / 14 / 18** (`radiusSm` … `radiusLg`).
- `minTouchTarget` **44** (referencia HIG).
- `cardElevationLight` **2** / `cardElevationDark` **1** para sombra suave sin exceso.

## Tipografía (`app_typography.dart`)
- `AppTypography.textTheme(ColorScheme)`: escala unificada para claro y oscuro (contraste vía `onSurface` / `onSurfaceVariant`).
- Títulos con **tracking** ligeramente negativo (sensación editorial / iOS).

## Componentes

### `lib/shared/widgets/`
| Widget | Función |
|--------|---------|
| `AppCard` | Tarjeta con borde tenue + sombra del `CardTheme` |
| `AppHeader` | Título grande + subtítulo + `trailing` |
| `AppSearchBar` | Campo de búsqueda relleno coherente con `InputDecorationTheme` |
| `AppFloatingActionButton` | FAB **circular**, colores del tema |
| `SectionTitle` | Título de sección + acción texto opcional |
| `EmptyStateCard` | Estado vacío amable con CTA opcional |
| `AppIconButton` | `IconButton` con **tooltip** opcional y color adaptable |

### `lib/shared/navigation/app_bottom_navigation.dart`
- `AppNavDestination`: modelo icono / icono activo / etiqueta.
- `AppBottomNavigation`: `NavigationBar` M3 con indicador basado en `secondaryContainer`.

### `lib/shared/layout/app_scaffold.dart`
- `AppScaffold`: `Scaffold` con fondo del tema y `FloatingActionButtonLocation.endFloat` por defecto.

## Tema global (`app_theme.dart`)
- Compone `CardTheme` (borde + `surfaceTintColor` muy bajo + sombra).
- `NavigationBarTheme` sin sombra dura (`elevation: 0`).
- `FloatingActionButtonTheme` con **`CircleBorder`**.
- `IconButtonTheme` con tamaño mínimo táctil.

## Pantalla de prueba
`HomePreviewScreen` muestra datos **ficticios** (cita, tareas, notas). Sirve para revisar jerarquía, tarjetas, nav y FAB; **no** sustituye al shell de producto ni a flujos finales.

## Límites de la versión
- Sin integración de datos reales ni permisos nativos extra.
- Sin nuevas dependencias; fuentes = **sistema** (SF en iOS).
- Preview puede duplicar patrones que luego vivirán en el app shell (refactor esperado en fase 3).

## Siguiente paso recomendado
1. **App shell** con router interno y estado de pestañas persistente.  
2. Sustituir progresivamente textos mock de `HomePreviewScreen` por view-models por feature.  
3. Galería opcional de componentes en debug si el equipo necesita QA visual rápida.

## Documentación relacionada
- `docs/version_0_23_design_system.md` — notas de versión y límites.
- `.cursor/rules/03_estilo_visual_aris.md` — tono y personalidad de producto **Aris**.
- `docs/roadmap_v0_22.md` — fases del producto.
