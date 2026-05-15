# Aris v0.26.1 — Ajustes visuales (calendario + Home)

Versión correctiva sin nuevas features grandes, sin backend ni dependencias nuevas. Producto **Aris**; sin referencias operativas a «Clara».

## Problemas detectados

1. **Calendario**: El selector **Día / Semana / Mes** no cambiaba la interfaz de forma creíble; las tres opciones parecían activas pero solo se mostraba una lista tipo “día” genérica.
2. **Inicio**: Hueco visual excesivo entre el bloque **Reciente** (conversación) y la **barra de chat** fija, por combinación de `padding` inferior muy generoso en el `ListView` y un `SizedBox` final redundante.

## Solución — Calendario (opción A)

Se implementaron **tres vistas simuladas** con datos mock únicamente:

| Modo | Comportamiento |
|------|----------------|
| **Día** | Franjas horarias verticales (aprox. 07:00–21:00) con eventos mock alineados por hora. |
| **Semana** | Columnas **L–D** desde el lunes de la semana actual; eventos distribuidos por día (`CalendarMockContent.eventsForWeekday`). |
| **Mes** | Cuadrícula del **mes en curso** (ancla `DateTime.now()`), **punto** en días con evento mock, **selección** de día; debajo, lista de eventos simulados del día (`eventsForMonthDay`). |

Archivos principales:

- `lib/features/calendar/data/calendar_mock_content.dart` — tipos/extensión de datos (`CalendarEventMock`), reparto semanal y marcadores mensuales.
- `lib/features/calendar/presentation/calendar_body_views.dart` — `CalendarDayView`, `CalendarWeekView`, `CalendarMonthView` + `mondayOfWeek`.
- `lib/features/calendar/presentation/calendar_screen.dart` — `SegmentedButton` conectado a las tres vistas y textos de ayuda por modo.

## Solución — Espaciado Home

- Eliminado el **`SizedBox` final** tras `RecentConversationCard` (evitaba “aire” extra al final del scroll).
- **Inicio**: En el `Scaffold`, el **`body` ya termina por encima** de la columna inferior (barra de chat + `NavigationBar`). Un `padding` inferior grande en el `ListView` solo añadía **zona de scroll vacía** y el hueco visual respecto al input. Se eliminó ese padding; no hace falta reservar altura extra.

## Historial (v0.26.1 inicial)

- Reducido **`AppSpacing.homeContentBottomInset`** de **168** a **128** px (enfoque incorrecto para este shell).
- Eliminado el **`SizedBox` final** tras `RecentConversationCard`.

**Corrección posterior**: se eliminó por completo `homeContentBottomInset` al comprobar que el chat **no** solapa el cuerpo.

## Otros cambios

- **`lib/core/app_meta.dart`**: `0.26.1` (Perfil muestra la línea coherente vía `AppMeta.userVisibleVersionLine`).
- **`pubspec.yaml`**: `0.26.1+1` y descripción breve.

## Archivos modificados (resumen)

- `lib/features/calendar/data/calendar_mock_content.dart` — ampliado.
- `lib/features/calendar/presentation/calendar_body_views.dart` — **nuevo**.
- `lib/features/calendar/presentation/calendar_screen.dart` — refactor.
- `lib/features/home/presentation/home_screen.dart`
- `lib/theme/app_spacing.dart`
- `lib/core/app_meta.dart`
- `pubspec.yaml`
- `docs/version_0_26_1_ui_fixes.md` — este documento.

## Riesgos pendientes

- **Vista mes**: la cuadrícula usa `childAspectRatio` fijo; en pantallas muy estrechas podría apretarse (ajuste fino v0.27).
- **Semana**: ancho de columna estrecho; títulos largos se **ellipsis** (esperado en mock).

## Siguiente paso recomendado

- v0.27: valorar **scroll horizontal** en vista semana si el texto sigue cortándose en locales con etiquetas largas.

## Verificación

- `flutter analyze` — sin issues.
- `flutter test` — OK.
