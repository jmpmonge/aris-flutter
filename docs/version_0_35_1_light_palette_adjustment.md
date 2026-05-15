# Aris v0.35.1 — Ajuste correctivo de la paleta del modo claro

## Introducción

Versión **0.35.1+1** corrige la percepción del **modo claro**: menos “lavado”, más **contraste** y sensación **premium cálida** (crema, azul marino, violeta), sin rediseñar el modo oscuro ni la arquitectura de pantallas/mocks.

## Marco técnico (jerárquico)

1. **`lib/theme/app colors.dart`** — fuente de verdad del `ColorScheme` claro y tokens asociados.
2. **`lib/theme/app_theme.dart`** — `ThemeData` (tarjetas, inputs, navegación, bordes).
3. **`lib/theme/app_spacing.dart`** — elevación de tarjetas en claro.
4. **Widgets con sombras propias** — alineación de opacidad de sombra según luminosidad.

## Naturaleza del cambio

Acto **puramente cosmético** sobre tokens y sombras: no introduce flujos nuevos, APIs ni dependencias.

## Competencia / alcance

- Solo **modo claro** y componentes que consumen `Theme.of(context).colorScheme` o sombras derivadas.
- **Modo oscuro**: intencionalmente **sin rediseño**; única interacción prevista: `inversePrimary` del dark alineado con el nuevo `primaryDeep` del claro.

## Procedimiento

1. **1ª instancia**: definición de paleta clara (marino, violeta, crema, textos azulados, verde de éxito).
2. **2ª instancia**: ajuste de sombras perceptibles, borde de `Card`, elevación y sombras locales en tarjetas compuestas.
3. **Control**: `flutter analyze` y `flutter test`.

## Problema detectado

- Fondos y tarjetas demasiado cercanos al blanco plano.
- Texto secundario poco diferenciado del desactivado.
- Acentos y sombras demasiado tenues; poco peso visual en CTAs y contenedores.

## Nueva dirección (modo claro)

- Lienzo **crema** (`#F7F1E8`), tarjetas **blanco cálido** (`#FFFCF8`).
- **Primario** azul marino (`#102A5C`); contenedor primario azul pastel (`#EAF1FF`).
- **Secundario** violeta (`#7B6CF6`) con contenedor lila (`#ECE9FF`).
- **Terciario** verde de éxito (`#25A66A`) y contenedor `#EAF7EF`.
- Texto principal `#102A43`, secundario `#5C667A`.
- Sombras con **tinte marino** perceptible sobre el fondo crema.

## Archivos modificados

| Archivo | Cambio |
|---------|--------|
| `lib/theme/app_colors.dart` | Nueva paleta clara; `success`; sombra clara; dark `inversePrimary` |
| `lib/theme/app_theme.dart` | Bordes/tinte de tarjeta; `navigationBar` `surfaceTintColor` |
| `lib/theme/app_spacing.dart` | `cardElevationLight` |
| `lib/shared/widgets/home_greeting_card.dart` | Sombra claro vs oscuro |
| `lib/shared/widgets/suggestion_card.dart` | Idem |
| `lib/shared/widgets/today_summary_card.dart` | Idem |
| `lib/shared/widgets/recent_conversation_card.dart` | Idem |
| `lib/shared/widgets/chat_input_bar.dart` | Idem |
| `lib/shared/widgets/local_action_card.dart` | Idem |
| `lib/core/app_meta.dart` | `0.35.1` |
| `pubspec.yaml` | `0.35.1+1` |
| `docs/light_theme_palette_v0_35_1.md` | Tabla de colores |
| `docs/version_0_35_1_light_palette_adjustment.md` | Este documento |

## Qué no se ha cambiado

- Navegación, rutas, mocks, servicios, backend, OpenAI, estructura de carpetas.
- **Modo oscuro** (colores de superficie y texto dark intactos).
- `lib/theme/app_typography.dart` (el contraste secundario se corrige vía `onSurfaceVariant`).

## Riesgos pendientes

- Pantallas con **colores fijos** añadidos en el futuro pueden desalinear el tema; conviene usar siempre `ColorScheme` / `AppColors`.
- Contraste en **imágenes o assets** externos no revisados.
- Ajuste fino por dispositivo (True Tone, nitidez) puede requerir micro‑tweaks de sombras.

## Siguiente paso recomendado

- Prueba visual en **iOS** (modo claro) y revisión de accesibilidad (WCAG) sobre pares texto/fondo clave.
- Opcional v0.35.2: auditar `InputDecoration` y bottom sheets con contenido muy denso.

## Conclusión

El modo claro gana **jerárquica visual** y **legibilidad** acorde a la referencia premium cálida, manteniendo **Aris** como producto y sin ampliar el alcance funcional.
