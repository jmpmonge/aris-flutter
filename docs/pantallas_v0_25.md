# Pantallas Aris v0.25 (simuladas)

Todas las pantallas usan **datos mock**. No hay llamadas de red ni permisos de calendario/correo.

## Inicio (`HomeScreen`)

- Estructura detallada en [home_structure_v0_25.md](./home_structure_v0_25.md).
- Barra de chat y bottom navigation viven en `AppNavigationShell` para mantener el input fijo sobre la nav.

## Calendario (`CalendarScreen`)

- Cabecera «Calendario».
- Selector visual Día / Semana / Mes (solo UI).
- Lista de eventos de ejemplo.

## Notas (`NotesScreen`)

- Buscador decorativo.
- Chips de notas rápidas y lista de recientes.
- Botón «Nueva nota» con feedback local (sin persistencia).

## Tareas (`TasksScreen`)

- Secciones «Hoy» y «Próximas».
- Estados completada/pendiente simulados.

## Perfil (`ProfileScreen`)

- Tarjeta de usuario (José).
- Filas: Cuenta, Preferencias, Integraciones, Privacidad, Ayuda.
- Bloque de versión de app (demostración).

## Asistente (`AssistantScreen`)

- Fondo y acentos azul profundo / violeta.
- Marca Aris y mensaje de bienvenida.
- Acciones rápidas: Hablar con Aris, Crear tarea/evento/nota, Resumir correo (solo UI).

## Navegación principal

Tabs en shell: **Inicio**, **Calendario**, **Notas**, **Tareas**, **Perfil**. El FAB secundario del shell se oculta en Inicio para no competir con la barra de chat.

## Documentación relacionada

- [version_0_25_pantallas_simuladas.md](./version_0_25_pantallas_simuladas.md) — alcance y referencias HTML vs premium.
