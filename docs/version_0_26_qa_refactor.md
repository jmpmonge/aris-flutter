# Aris v0.26 — QA, limpieza y consistencia visual

## Alcance

Revisión y estabilización tras **v0.25**: sin nuevas funcionalidades de producto, sin backend, sin APIs ni dependencias nuevas.

## Archivos revisados

### Tema y tokens

- `lib/theme/app_spacing.dart` — nuevos tokens: iconos (`iconSm`–`iconFab`), radios (`radiusTail`), scroll (`fabStackClearance`), medidas de layout (columna calendario, avatar, chips, ancho burbuja) y sombras nombradas (`shadowBlur*` / `shadowOffset*`). *Nota: `homeContentBottomInset` se eliminó al corregir el layout del Home (v0.26.1+).*
- `lib/core/app_meta.dart` — **fuente única** de la cadena de versión visible (`userVisibleVersionLine`).

### Features — datos mock separados de UI

- `lib/features/home/data/home_mock_content.dart`
- `lib/features/calendar/data/calendar_mock_content.dart`
- `lib/features/notes/data/notes_mock_content.dart`
- `lib/features/profile/data/profile_mock_content.dart`
- `lib/features/assistant/data/assistant_mock_content.dart`

### Features — presentación

- `lib/features/home/presentation/home_screen.dart` — usa mock; navegación al asistente desde cabecera; sin padding inferior artificial en el `ListView` (shell no solapa el contenido).
- `lib/features/calendar/presentation/calendar_screen.dart`
- `lib/features/notes/presentation/notes_screen.dart`
- `lib/features/profile/presentation/profile_screen.dart` — versión desde `AppMeta`.
- `lib/features/tasks/presentation/tasks_screen.dart`
- `lib/features/assistant/presentation/assistant_screen.dart`

### Widgets compartidos

- `lib/shared/widgets/home_brand_header.dart` — botón tonal «Hablar con Aris» (acceso al asistente en Inicio).
- `lib/shared/widgets/home_greeting_card.dart`
- `lib/shared/widgets/recent_conversation_card.dart`
- `lib/shared/widgets/today_summary_card.dart`
- `lib/shared/widgets/suggestion_card.dart`
- `lib/shared/widgets/chat_input_bar.dart`
- `lib/shared/widgets/quick_action_card.dart`

### Navegación (sin cambio de contrato)

- `lib/shared/navigation/app_navigation_shell.dart` — comportamiento v0.25 mantenido: chat fijo en Inicio, FAB en demás pestañas.

### App

- `lib/app.dart`, `lib/main.dart` — arranque comprobado con `flutter analyze` / `flutter test`.

## Problemas encontrados

1. **Padding “mágico”** (`100`, `168`, anchos `52`, etc.) repetido entre pantallas sin token común.
2. **Sombras y tamaños de icono** duplicados en varias tarjetas; riesgo de deriva visual.
3. **Mocks embebidos** en pantallas (Home, Calendario, Notas, Perfil, Asistente) mezclando contenido de demostración con widgets.
4. **Acceso al asistente en Inicio**: el FAB se oculta en la pestaña Inicio (v0.25); faltaba un atajo explícito en la cabecera.
5. **Versión en Perfil** desalineada con `pubspec` (texto fijo `v0.25.0`).
6. **Nombre del producto**: verificado que en `lib/` no quedan referencias operativas a «Clara».

## Cambios realizados

- Centralización de **insets** para FAB y contenido del Home en `AppSpacing`.
- Centralización de **metadatos de versión** en `AppMeta` y uso en Perfil.
- Extracción de **listas y textos mock** a `features/*/data/*_mock_content.dart`.
- Sustitución de **números sueltos** por tokens en tarjetas home, chat, calendario, notas, perfil y tareas.
- `HomeBrandHeader` con **`IconButton.filledTonal`** para abrir `AssistantScreen` (además del FAB en otras pestañas).

## Riesgos pendientes

- **Orden de imports** tras `dart format`: convención del equipo (si usan `directives_ordering` estricto) podría exigir ajuste manual.
- **`MailScreen`** sigue en el árbol de features pero **fuera del shell principal**; si se elimina en el futuro, limpiar exports/rutas huérfanas.
- **Duplicación de navegación al asistente** (cabecera Inicio + FAB): coherente con UX, pero en v0.27 podría unificarse vía callback inyectado en el shell.

## Siguiente paso recomendado (v0.27)

Ver lista de TODOs técnicos en la misma serie de releases (`docs/revision_visual_v0_26.md` y sección inferior de este documento).

## Verificación ejecutada

- `dart format lib`
- `flutter analyze` — sin issues
- `flutter test` — OK

Versión de proyecto: **0.26.0+1** (`pubspec.yaml`).

## TODOs técnicos sugeridos para v0.27

1. **Router declarativo** (`go_router` u otro) solo si el equipo lo prioriza; valorar coste frente a `Navigator` imperativo actual.
2. **`package_info_plus`** (o similar) para alinear `AppMeta` con build real en CI — requiere dependencia explícita y justificación.
3. **Capa `presentation` + viewmodels** por feature para estado de checkbox de tareas sin mutar modelos en listas.
4. **Tests de integración** mínimos: apertura de Asistente desde Inicio + desde FAB.
5. **Semántica y `Semantics`** en barra de chat y burbujas «Reciente» para VoiceOver.
6. **Documentar** en `navigation_shell` la sustitución Mail → Tareas si aún no está alineado con el código.
7. **Review de tema oscuro** en gradiente del Asistente (contraste de `QuickActionCard` sobre fondo muy saturado).
