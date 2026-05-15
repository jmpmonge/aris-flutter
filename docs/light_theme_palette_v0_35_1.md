# Paleta modo claro — Aris v0.35.1

Referencia rápida de colores aplicados en **`AppColors.lightScheme`** (Material 3). El modo oscuro no forma parte de esta revisión.

## Colores principales

| Rol | Hex | Uso |
|-----|-----|-----|
| Primary (marino) | `#102A5C` | Botones rellenos, FAB, iconos seleccionados (nav), titulares fuertes vía tema |
| On primary | `#FFFBF7` | Texto e iconos sobre primario/secundario/error en claro |
| Primary container | `#EAF1FF` | Fondos suaves, chips primarios, gradientes (p. ej. saludo) |
| On primary container | `#071B3A` | Texto sobre contenedor primario |
| Secondary (violeta) | `#7B6CF6` | Acentos, etiquetas destacadas |
| Secondary container | `#ECE9FF` | Indicador nav, fondos violeta pastel |
| On secondary container | `#2A1F55` | Texto sobre lila |
| Tertiary (éxito) | `#25A66A` | Acento verde discreto |
| Tertiary container | `#EAF7EF` | Pastel verde (chips, gradientes) |
| On tertiary container | `#0A4D32` | Texto sobre verde pastel |
| Canvas / scaffold | `#F7F1E8` | `surfaceContainerLowest` + `scaffoldBackgroundColor` |
| Surface (tarjeta) | `#FFFCF8` | `Card`, piezas tipo “hoja” |
| Surface low | `#FEFAF2` | Contenedores bajos |
| Surface / mid | `#F5EDE3` | Agrupaciones |
| Surface high (input) | `#EFE8DE` | Relleno de campos |
| Surface highest | `#E8E0D6` | Énfasis de contenedor |
| Texto principal | `#102A43` | `onSurface` |
| Texto secundario | `#5C667A` | `onSurfaceVariant` |
| Outline | `#E8DFD2` | Bordes |
| Outline variant | `#F3EDE4` | Divisores suaves |
| Sombra (token) | `#102A5C` @ ~27 % | `ColorScheme.shadow` (combinado con elevación) |

## Tokens adicionales en `AppColors`

| Nombre | Hex | Notas |
|--------|-----|--------|
| `violetSoft` | `#8B7CF6` | Punto intermedio en gradientes (p. ej. asistente en claro) |
| `textTertiaryLight` | `#7A8499` | Reservado para refinados futuros |
| `softOrange` | `#FFF0DF` | Documentado / extensiones |
| `softPurple` | `#EFEAFF` | Cercano al contenedor secundario |

## Implementación

- Definición: `lib/theme/app_colors.dart` → getter `lightScheme`.
- Consumo: `ThemeData` en `lib/theme/app_theme.dart`; widgets vía `Theme.of(context).colorScheme`.

## Compatibilidad

- **Oscuro**: mismos nominales que v0.35.0 salvo `inversePrimary` → `#102A5C` coherente con el nuevo marino global.
