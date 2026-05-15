# Design system Clara / Aris — v0.23

## Principios
- **Aris**: producto sobrio y confiable; primario azul-verdoso profundo, sin sensación “fría gris”.
- **Clara**: cercanía y guía; acento cálido arena/dorado suave en contenedores y FAB, sin competir con el primario en cada vista.
- **Superficies**: lienzo y tarjetas en **blancos/cremas cálidos**, bordes discretos (línea `outline` suave).
- **Tipo**: pocas jerarquías fuertes; cuerpo ~17 / 15 pt lógicos, interlineado holgado para lectura móvil.
- **Motion**: sin animaciones añadidas en v0.23; el tema usa ripple estándar para feedback táctil.

## Tokens (`lib/theme/`)

### Color (`AppColors`)
| Token | Uso |
|------|-----|
| `arisDeep` / `arisMid` | Marca, navigation selected, énfasis |
| `claraAccent` / `claraAccentSoft` | Presencia asistente: FAB, badges suaves, ilustraciones vacías |
| `canvas` | Fondo de `Scaffold` (no blanco puro) |
| `surface` | Tarjetas elevadas conceptualmente |
| `surfaceRaised` / `surfaceTint` | Rellenos de campo, bloques secundarios vía `ColorScheme.surfaceContainer*` |
| `textPrimary` / `textSecondary` / `textTertiary` | Mapeados a `onSurface` y variantes en el scheme |

`AppColors.lightScheme` construye el `ColorScheme` M3 usado por `AppTheme.light()`.

### Espaciado (`AppSpacing`)
- Base **4 y 8**: `xxs` 4 → `xxl` 48.
- Radios: `radiusSm` 10, `radiusMd` 14, `radiusLg` 18.
- `minTouchTarget` 44 (referencia HIG).

### Tipografía (`AppTypography`)
- `TextTheme` derivado del esquema: títulos con **letterSpacing ligeramente negativo** (sensación editorial iOS).
- Cuerpo y etiquetas respetan `onSurface` / `onSurfaceVariant`.

## Componentes (`lib/shared/widgets/`)

### AppCard
Contenedor con borde sutil y `AppSpacing.radiusLg`. Soporta `onTap` opcional + `semanticLabel`.

### AppHeader
Título `headlineMedium` + subtítulo opcional en color variant; `trailing` para iconografía o acciones puntuales.

### AppSearchBar
`TextField` relleno que respeta `InputDecorationTheme`; icono de búsqueda con **área táctil mínima**.

### AppFloatingActionButton
Envoltorio con tamaño ≥ objetivo táctil; colores desde **`FloatingActionButtonTheme`** (terciario Clara).

### AppBottomNavigation
`NavigationBar` con lista de `AppNavDestination` (icono / icono seleccionado / etiqueta).

### SectionTitle
`titleMedium` + `TextButton` opcional alineado a la derecha (“Ver todo”, filtros, etc.).

### EmptyStateCard
Combinación de icono en círculo (`tertiaryContainer`), título, mensaje alineado con tono Clara y **CTA opcional** (`FilledButton`).

## Uso recomendado
1. **No** usar hexadecimales sueltos en features: tomar color del `Theme.of(context).colorScheme` o ampliar `AppColors` si falta un token.
2. **No** mezclar escalas de espacio arbitrarias: preferir múltiplos de `AppSpacing`.
3. Para nuevos componentes, seguir el patrón *theme-first* (leer colores y textos del tema).

## Evolución
- **v0.24+**: posible `ThemeExtension` para tokens de producto extra (elevación Clara, gradientes muy suaves) sin romper M3.
- **Oscuro**: no incluido en v0.23; añadir `AppColors.darkScheme` + `AppTheme.dark()` cuando roadmap lo pida.

## Referencias
- `docs/version_0_23_design_system.md` — notas de entrega
- `.cursor/rules/03_estilo_visual_clara.md` — personalidad y límites
- `docs/roadmap_v0_22.md` — fase 2 sistema visual
