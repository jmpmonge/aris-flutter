# Aris v0.36 — Responsive móvil y marco web tipo iPhone

## Introducción

Versión **0.36.0+1** unifica el comportamiento **mobile-first** en dispositivos reales y en **Flutter Web**: ancho máximo tipo teléfono en escritorio, sin estirar la UI como una web clásica, manteniendo tema claro/oscuro/sistema y la navegación actual.

## Marco técnico

1. **`lib/shared/layout/responsive_app_frame.dart`** — envoltorio global (web).
2. **`lib/app.dart`** — `MaterialApp.builder` aplica el frame.
3. **`lib/shared/layout/breakpoints.dart`** — constantes de ancho y márgenes web.
4. Ajustes de **SafeArea**, **bottom sheets** y **targets táctiles** en pantallas y widgets listados abajo.

## Naturaleza del cambio

Refactor de **layout y ergonomía**; sin nuevas features de negocio, sin backend ni dependencias nuevas.

## Comportamiento

### Móvil nativo (iOS / Android)

- El frame **no aplica** (`kIsWeb == false`): la app usa todo el ancho y alto del viewport.
- Pestañas principales: `SafeArea(top: true, bottom: false)` para respetar **notch/status** sin duplicar el padding inferior ya cubierto por la **barra de chat** (solo Inicio) + **NavigationBar** en el `Scaffold`.

### Flutter Web

- **Viewport estrecha** (ancho ≤ 430 px + márgenes horizontales del marco): banda exterior con fondo **shell** alineado al tema; contenido a ancho completo del viewport.
- **Viewport ancha**: columna centrada de **430 px** (aprox. iPhone grande), bordes redondeados, sombra suave; `MediaQuery.size` se recorta al rectángulo del “dispositivo” para que diálogos y hojas inferiores respeten el ancho móvil.

### Tema

- El color **exterior** del marco en web se deriva de `surfaceContainerLowest` con un ligero tinte de `primary` (distinto en claro u oscuro), vía `ResponsiveAppFrame.shellBackground`.

## Pantallas revisadas (SafeArea / scroll)

| Pantalla | Ajuste |
|----------|--------|
| `HomeScreen` | `SafeArea(top: true, bottom: false)` + `ListView` existente; input inferior fuera del body en el shell. |
| `CalendarScreen` | Igual; `ListView` con `fabStackClearance`. |
| `NotesScreen` | Igual; `Column` + `Expanded` + scroll interno en listas. |
| `TasksScreen` | Igual; `CustomScrollView`; filas con más altura táctil. |
| `MailScreen` | Igual; `ListView` con padding inferior. |
| `ProfileScreen` | Igual; `ListView`. |
| `SettingsScreen` | Ruta modal: padding inferior `+ MediaQuery.padding.bottom`. |
| `AssistantScreen` | `SafeArea` + `ListView`; padding inferior + inset del sistema; botón cerrar con target 44. |

## Formularios / bottom sheets

- `LocalActionFormSheet`: en viewports más anchos que 430 px, `showModalBottomSheet` usa `constraints` con `maxWidth: 430` (constante `LayoutBreakpoints.webMobileFrameMaxWidth`).
- Scroll interno y `viewInsets` para teclado se mantienen vía `_paddingFor`.

## Targets táctiles

- `LocalActionCard`: botón eliminar con `minimumSize` 44×44.
- `QuickActionCard`: `minHeight` 44 en la fila.
- `TasksScreen`: `CheckboxListTile` con más padding vertical explícito.
- `ChatInputBar` / `AppFormButton`: ya usaban ~44 px de altura mínima en controles clave.

## Archivos tocados (resumen)

- `lib/shared/layout/responsive_app_frame.dart` (nuevo)
- `lib/shared/layout/breakpoints.dart`
- `lib/app.dart`
- `lib/shared/widgets/local_action_form_sheet.dart`
- `lib/shared/widgets/local_action_card.dart`
- `lib/shared/widgets/quick_action_card.dart`
- `lib/features/home/presentation/home_screen.dart`
- `lib/features/calendar/presentation/calendar_screen.dart`
- `lib/features/notes/presentation/notes_screen.dart`
- `lib/features/tasks/presentation/tasks_screen.dart`
- `lib/features/mail/presentation/mail_screen.dart`
- `lib/features/profile/presentation/profile_screen.dart`
- `lib/features/settings/presentation/settings_screen.dart`
- `lib/features/assistant/presentation/assistant_screen.dart`
- `lib/core/app_meta.dart`, `pubspec.yaml`
- `docs/responsive_app_frame_v0_36.md`, este documento

## Qué no se ha cambiado

- Navegación por pestañas, mocks, servicios locales, rutas y lógica de negocio.
- Paleta v0.35.1 y `ThemeService`.

## Riesgos pendientes

- En web, **MediaQuery** dentro del marco fuerza `size` al rectángulo del frame; casos raros con plugins que lean otras subcampos de `MediaQuery` pueden necesitar prueba manual.
- **Tablets nativas** en horizontal siguen usando ancho completo (no se simula marco; opción futura).

## Siguiente paso recomendado

- Prueba manual en **Chrome/Safari** (ventana ancha y estrecha) y en **iPhone/Android** real.
- Opcional: `LayoutBuilder` en una pantalla densa para refinar breakpoints por orientación.

## Conclusión

Aris se percibe como **app móvil premium** en web y nativo, con límites de ancho coherentes y mejor ergonomía de áreas seguras y toques.
