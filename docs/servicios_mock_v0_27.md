# Servicios mock — v0.27

Ubicación: `lib/core/services/`. Cada servicio es una clase `abstract final` con métodos **estáticos** que devuelven colecciones o valores desde `lib/core/mock/`.

## API interna (no HTTP)

| Servicio | Métodos principales | Datos |
|----------|---------------------|--------|
| `CalendarService` | `getTodayEvents([day])`, `getWeekEvents(dayInWeek)`, `getMonthDayHasEvent(month, day)`, `getMonthEvents(month, dayOfMonth)`, `getHomeHighlightEvents([day])` | `MockEvents` |
| `TaskService` | `getTodayTasks()`, `getUpcomingTasks()`, `getHomeHighlightTasks()` | `MockTasks` |
| `NoteService` | `getQuickLabels()`, `getRecentNotes()`, `getHomeHighlightNotes()` | `MockNotes` |
| `MailService` | `getFolderLabels()`, `getInboxPreview({folderIndex})` | `MockMails` |
| `UserService` | `getCurrentUser()`, `getProfileMenuEntries()`, `getHomeSummaryLine()`, `getHomeSuggestionLine()`, `getGreetingForNow()` | `MockUser` |
| `ChatService` | `getRecentConversation()` | `MockChatMessages` |
| `AssistantService` | `getQuickActions()` | `MockAssistantActions` |

## Consumo por pantalla

- **Home**: `UserService`, `CalendarService.getHomeHighlightEvents`, `TaskService.getHomeHighlightTasks`, `NoteService.getHomeHighlightNotes`, `ChatService`.
- **Calendario**: `CalendarService` en día/semana/mes (`calendar_body_views.dart`).
- **Notas / Tareas / Mail / Perfil / Asistente**: servicios homónimos en el `build` o `initState`.

## Notas

- `getInboxPreview` sin `folderIndex` devuelve todos los correos mock (uso interno opcional); la UI de `MailScreen` filtra por carpeta.
- No hay caché ni invalidación: cada llamada devuelve datos equivalentes (listas nuevas o vistas inmutables según el método).
