# ResponsiveAppFrame — refer técnica (v0.36)

## Ubicación

`lib/shared/layout/responsive_app_frame.dart`

## Activación

- **Solo Flutter Web** (`foundation kIsWeb`).
- Nativo: devuelve el `child` sin modificar.

## Constantes relacionadas

Definidas en `lib/shared/layout/breakpoints.dart`:

| Constante | Valor | Uso |
|-----------|-------|-----|
| `webMobileFrameMaxWidth` | `430` | Ancho máximo de la columna “teléfono” en web ancha. |
| `webFrameOuterPaddingH` | `20` | Margen horizontal exterior. |
| `webFrameOuterPaddingV` | `16` | Margen vertical exterior. |
| `webFrameBorderRadius` | `28` | Radio de la silueta tipo dispositivo. |

## Criterio “web ancha”

Se dibuja marco con sombra y recorte si:

`constraints.maxWidth > webMobileFrameMaxWidth + 2 * webFrameOuterPaddingH`

Si no, solo se pinta el **fondo shell** a pantalla completa (sin recorte ni sombra).

## Fondo exterior (`shellBackground`)

- Base: `ColorScheme.surfaceContainerLowest`.
- Mezcla: `primary` al ~5 % (claro) u ~10 % (oscuro) con `Color.alphaBlend`.
- Objetivo: que el exterior se sienta **cálido** en claro y **profundo** en oscuro, sin duplicar el lienzo interior.

## Interior del marco

1. `ColoredBox` con `Theme.of(context).scaffoldBackgroundColor` (coherente con `AppTheme`).
2. `MediaQuery.copyWith(size: Size(430, innerH))` para que descendientes vean ancho de móvil.
3. `innerH = boundedHeight - 2 * webFrameOuterPaddingV`; si no hay alto útil, se **omite** el marco y se muestra solo el shell + child a pantalla completa (evita layouts imposibles).

## Integración

`lib/app.dart`:

```dart
MaterialApp(
  builder: (context, child) {
    return ResponsiveAppFrame(child: child ?? const SizedBox.shrink());
  },
  ...
);
```

Así, **todas** las rutas (`Navigator`, sheets modales, etc.) quedan bajo el mismo envoltorio.

## Coherencia con bottom sheets

`LocalActionFormSheet` limita `maxWidth` a `webMobileFrameMaxWidth` cuando el ancho disponible es mayor, para que formularios no se estiren en monitores anchos aunque el sheet se muestre fuera del `ClipRRect` (sigue anclado al centro del viewport).

## Pruebas rápidas

1. `flutter run -d chrome` — redimensionar por encima y por debajo del umbral del marco.
2. Cambiar **tema** (claro/oscuro/sistema) y comprobar tono del shell exterior.
3. Abrir **Ajustes** y un **formulario Aris**; comprobar scroll y ancho.
