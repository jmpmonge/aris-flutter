# Aris v0.33 — Formularios locales rápidos

## Objetivo

Permitir crear **tareas, notas, eventos y acciones de correo simuladas** desde la UI (bottom sheets) además del chat en Inicio, manteniendo todo **local**, sin backend ni integraciones reales.

## Componentes nuevos (`lib/shared/widgets/`)

| Widget | Función |
|--------|---------|
| `form_section_title.dart` | `FormSectionTitle` — títulos de bloque en formularios. |
| `app_text_field.dart` | `AppTextField` — campo de texto con decoración del tema. |
| `app_form_button.dart` | `AppFormButton` — botón relleno o contorneado a ancho completo. |
| `local_action_form_sheet.dart` | `LocalActionFormSheet` — hojas modales: tarea, nota, evento, correo. |

Modal elegido: **bottom sheet** con handle, bordes superiores redondeados y `isScrollControlled` + inset de teclado.

## Modelo y servicio

- `LocalActionModel`: prioridad de tarea (`LocalTaskPriority`), categoría de nota, texto de fecha/hora de evento (`eventWhenText`); `statusChipLabel` según estado; `copyWith` para futuras ediciones.
- `LocalActionService`: `createTask`, `createNote`, `createEvent`, `createMailAction`; `removeAction`; `toggleActionCompleted` (tareas y mail); persistencia existente (`shared_preferences`) sin cambiar de motor.

Las creaciones desde formulario usan **`LocalActionStatus.pending`**. Las del chat siguen en **`simulated`**.

## Pantallas y acciones

| Pantalla | Cómo se abre el formulario |
|----------|----------------------------|
| **TasksScreen** | Botón **+** en cabecera → tarea. |
| **NotesScreen** | «Nueva nota» (SectionTitle) → nota. |
| **CalendarScreen** | Botón **+** en cabecera → evento. |
| **MailScreen** | Botón **+** en cabecera → correo (acceso vía **Perfil → Mail**). |
| **AssistantScreen** | Tarjetas: crear tarea / evento / nota / acción correo («Resumir correo» abre formulario mail). |

**Perfil**: nueva entrada de menú **Mail** que navega a `MailScreen`.

## Tarjeta de acción

`LocalActionCard`: chips de tipo, estado (SIMULADO / PENDIENTE / LISTO) y metadatos; **completar** y **eliminar** en modo no compacto (tareas y correo pueden alternar completado).

## Validación

- Título (o asunto en mail) obligatorio; mensaje de error en campo o feedback visual estándar.

## Límites

- Sin date picker real; evento usa **texto libre** para fecha/hora.
- Sin envío de correo.
- Sin sincronización multi-dispositivo.
- Dropdown de categoría de nota acotado a valores demo.

## Siguiente paso sugerido

Unificar esquema JSON (`v: 2`) si el modelo crece; date picker opcional sin dependencias pesadas cuando el producto lo exija.
