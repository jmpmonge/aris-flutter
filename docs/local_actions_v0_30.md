# Acciones locales simuladas (v0.30)

## Modelo

**`lib/core/models/local_action_model.dart`**

- `id`, `type` (`task` | `note` | `event` | `mail` | `general`), `title`, `description`, `sourceText`, `createdAt`
- `status`: `simulated` | `pending` | `completed` (en esta versión solo se asigna `simulated`)
- `optionalIntentConfidence`: copia de la confianza del clasificador v0.29 (decorativa)

## Servicio

**`lib/core/services/local_action_service.dart`** (singleton por lista estática)

- `createFromIntent(IntentModel)` → crea acción solo para `task`, `note`, `event`, `mail`
- `getRecentActions()`, `getActionsByType(LocalActionType)`
- `getMostRecentAction()` para Inicio
- `clearAll()` para pruebas
- `revision` (`ValueNotifier<int>`) para refrescar UI sin Provider/Bloc

## Conexión con la intención

El mapeo es directo desde `IntentType` a `LocalActionType` para los cuatro tipos accionables. `general` y `unknown` no producen fila nueva: el usuario recibe el mensaje genérico en chat.

## Pantallas

| Pantalla | Sección / widget |
|----------|------------------|
| `TasksScreen` | «Creadas por Aris» + `LocalActionCard` |
| `NotesScreen` | «Notas creadas por Aris» + cards compactas horizontales |
| `CalendarScreen` | «Eventos creados por Aris» bajo la vista Día/Semana/Mes |
| `MailScreen` | «Acciones de correo sugeridas» encima de la bandeja mock |
| `HomeScreen` | `LatestArisActionSection` |

## UI compartida

**`lib/shared/widgets/local_action_card.dart`**: tipo, título, descripción, chips **SIMULADO** + tipo, marca de tiempo breve.

## Chat

**`ChatService`** invoca `LocalActionService.createFromIntent` en cada envío válido y usa mensajes fijos:

- Tarea: *He creado una tarea simulada a partir de tu mensaje.*
- Nota: *He creado una nota simulada.*
- Evento: *He creado un evento simulado para revisar después.*
- Mail: *He preparado una acción simulada relacionada con correo.*
- General: *He recibido tu mensaje. No he creado ninguna acción específica.*

## Qué **no** incluye esta versión

- Sin backend, sin OpenAI, sin API de terceros.
- Sin base de datos ni almacenamiento en disco.
- Sin correo, calendario o tareas “reales” enlazadas al clasificador.

## Riesgos

- Misma limitación que el clasificador por palabras clave (falsos positivos).
- Estado solo en RAM: reiniciar la app vacía el historial de acciones.

## Próximo paso sugerido

Definir capa de persistencia y reglas de fusión con datos mock antes de exponer la app a un backend.
