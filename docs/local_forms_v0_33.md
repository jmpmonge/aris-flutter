# Formularios locales v0.33

## Resumen

Formularios **modales inferiores** para alta manual de acciones simuladas conectadas a `LocalActionService`. Misma persistencia que v0.31 (JSON en `SharedPreferences`).

## Formularios

### Tarea
- Campos: título (obligatorio), descripción opcional, prioridad (baja / media / alta).
- Crea `LocalActionType.task` con `pending` y `taskPriority`.

### Nota
- Campos: título (obligatorio), contenido, categoría opcional (Trabajo, Personal, Ideas).
- Crea `note` con `noteCategory` opcional.

### Evento
- Campos: título (obligatorio), descripción, **fecha/hora en texto** (ej. «Mañana 10:00»).
- Crea `event` con `eventWhenText` y descripción compuesta localmente.

### Correo
- Campos: asunto (obligatorio), descripción.
- Crea `mail` con `pending`. **No envía** nada.

## Pantallas afectadas

- `tasks_screen.dart`, `notes_screen.dart`, `calendar_screen.dart`, `mail_screen.dart`, `assistant_screen.dart`, `profile_screen.dart` (ruta a Mail), `mock_user.dart`, `icon_from_key.dart`.

## Cómo se relacionan con el chat

- Chat → `createFromIntent` → estado `simulated`.
- Formularios → métodos `create*` → estado `pending`.
- Ambos aparecen en las mismas listas filtradas por tipo.

## Qué no incluye esta versión

- Backend, APIs, OpenAI, calendario IMAP real.
- Nuevas dependencias (solo widgets y API existentes).

## Riesgos

- Listas largas de acciones sin paginación.
- Texto de evento no validado semánticamente.

## Recomendación v0.34+

Edición in-line de acciones y filtros por estado o prioridad.
