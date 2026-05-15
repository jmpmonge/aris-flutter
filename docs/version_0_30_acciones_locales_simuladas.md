# Aris v0.30 — Acciones locales simuladas

## Resumen

Tras clasificar un mensaje del chat de Inicio, si la intención es **tarea, nota, evento o correo**, Aris **crea una entrada local simulada** en memoria y la muestra en la pantalla correspondiente. No hay persistencia, backend ni integraciones reales.

## Qué se crea

| Intención (`IntentType`) | Modelo | Pantalla |
|--------------------------|--------|----------|
| `task` | `LocalActionModel` tipo `task` | Tareas → sección **Creadas por Aris** |
| `note` | `note` | Notas → **Notas creadas por Aris** (carrusel horizontal) |
| `event` | `event` | Calendario → **Eventos creados por Aris** (debajo de la vista activa) |
| `mail` | `mail` | Mail → **Acciones de correo sugeridas** |
| `general` / `unknown` | No se crea acción | Solo texto en conversación |

## Flujo técnico

1. `ChatService.sendLocalMessage` clasifica con `IntentClassifierService`.
2. `LocalActionService.createFromIntent` inserta la acción si el tipo aplica (lista estática + `ValueNotifier` `revision`).
3. La respuesta de Aris en chat comunica la creación simulada con los textos de v0.30.
4. Las pantallas escuchan `LocalActionService.revision` y repintan con `LocalActionCard`.

## Inicio

`LatestArisActionSection` muestra la **última** acción creada (si existe), entre **HOY** y **RECIENTE**.

## Sustitución futura

- Sustituir la lista en memoria por repositorio + API o almacenamiento local.
- Mantener `LocalActionModel` como DTO de presentación o alinearlo con el contrato del backend.

## Límites de la versión

- Lista global estática: se pierde al cerrar la app.
- No se vinculan acciones a los modelos mock existentes (`TaskModel`, `EventModel`, etc.): conviven en UI.
- `LocalActionStatus` admite `pending` y `completed` pero en v0.30 solo se usa `simulated`.

## Riesgos pendientes

- Duplicados: cada envío crea una nueva acción aunque el texto sea similar.
- Clasificador por palabras clave puede disparar tipos equivocados; la acción refleja esa intención errónea.

## Siguiente paso recomendado

Persistencia local (p. ej. `shared_preferences` o `hive` planificado) con identificadores estables y deduplicación opcional antes de conectar backend.
