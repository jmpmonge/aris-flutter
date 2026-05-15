# Aris v0.31 — Persistencia local de acciones simuladas

## Contexto

En v0.30 las acciones locales creadas desde el chat ya vivían en un singleton (`LocalActionService`), por lo que **no debían perderse al cambiar de pestaña** dentro de la misma sesión. La mejora de v0.31 es **formalizar la fuente única de verdad**, **persistir de forma opcional y ligera en disco** para sobrevivir al cierre de la app, y **mejorar la UI** con estados vacíos claros.

## Decisión de persistencia

| Opción | Elección |
|--------|----------|
| A. Solo memoria | Rechazada como única solución: el usuario pidió razonablemente mantener datos tras reinicio. |
| B. `shared_preferences` | **Elegida**: dependencia oficial y mantenida, adecuada para un **único JSON** pequeño sin esquema relacional. |

**No** se usa SQLite, Hive, Isar ni Firebase en esta fase.

## Qué se guarda

- Clave: `aris_local_actions_v1`.
- Valor: JSON `{ "v": 1, "items": [ LocalActionModel… ] }` (campos de `LocalActionModel`, sin datos de autenticación ni credenciales).

## Qué no se guarda

- Conversación de chat.
- Clasificaciones sueltas sin acción materializada.
- Tokens, correo real, calendario real o PII añadida fuera del texto demo del usuario.

## Integración

- `main.dart`: `WidgetsFlutterBinding.ensureInitialized()` → `await LocalActionService.initialize()` → `runApp`.
- `LocalActionService.createFromIntent` sigue siendo el único punto de creación desde el chat; tras insertar, se programa `_persist()` asíncrona.
- `clearLocalActions()` borra memoria y la clave en preferencias.

## Pantallas consumidoras

Siguen leyendo **solo** de `LocalActionService` (sin listas paralelas): Inicio (`LatestArisActionSection`), Tareas, Notas, Calendario, Mail.

## UI

Cada sección «Creadas por Aris» / equivalente muestra un **estado vacío** (`LocalActionEmptyState`) cuando no hay ítems, en lugar de ocultar el bloque o mostrar una lista vacía confusa.

## Límites de la versión

- Tamaño no acotado del JSON: en demo es aceptable; producción exigiría límite o paginación.
- Concurrencia: persistencias encadenadas con `unawaited`; en uso normal no hay conflicto.
- No hay cifrado: solo datos de demostración; no usar para secretos.

## Riesgos pendientes

- Migración de esquema si `LocalActionModel` cambia (hoy solo versión `v: 1` en payload).
- Tests e2e deben mockear `SharedPreferences` si ejercitan `initialize`.

## Siguiente paso recomendado

- v0.32+: repositorio abstracto + inyección para tests; opcionalmente cifrado si algún campo dejara de ser puramente demo.
