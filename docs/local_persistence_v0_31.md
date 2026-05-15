# Persistencia local — acciones simuladas (v0.31)

## Tipo de persistencia

**`shared_preferences`** con un único `String` que contiene JSON (lista de acciones).

### Por qué esta opción

- Cumple el objetivo de **supervivencia al reinicio** sin añadir motor SQL ni modelos de migración complejos.
- API estable y ampliamente usada en el ecosistema Flutter.
- Coherente con el requisito de **no** introducir Hive/Isar/SQLite en esta fase.

### Alternativa descartada

Solo memoria (`List` estática) garantiza persistencia durante la sesión pero **no** tras matar la app; por eso se combinó singleton (fuente única en runtime) + guardado ligero en disco.

## Qué se guarda

Objeto raíz:

```json
{
  "v": 1,
  "items": [ /* LocalActionModel.toJson() × N */ ]
}
```

Cada ítem incluye: `id`, `type`, `title`, `description`, `sourceText`, `createdAt` (ISO8601), `status`, `optionalIntentConfidence` opcional.

Orden: el primer elemento es **la acción más reciente** (misma convención que en memoria).

## Qué no se guarda

- Mensajes de `ChatService` / `ChatMessageModel`.
- Intenciones sin acción asociada.
- Datos de usuario reales o autenticación (no existe en la app).

## LocalActionService

| Método | Rol |
|--------|-----|
| `initialize()` | Carga desde `SharedPreferences`; limpia si el JSON es inválido. |
| `createFromIntent` | Crea en memoria y programa guardado. |
| `getRecentActions` / `getActionsByType` / `getMostRecentAction` | Lectura; sin copias desconectadas en pantallas. |
| `clearLocalActions` | Borra memoria + clave persistida. |

`revision` (`ValueNotifier`) notifica hidratación, creación y borrado.

## Pantallas

- **HomeScreen**: bloque «Última acción de Aris» si hay datos.
- **TasksScreen**: «Creadas por Aris» + vacío elegante si no hay tareas locales.
- **NotesScreen**: «Notas creadas por Aris» idem.
- **CalendarScreen**: «Eventos creados por Aris» idem.
- **MailScreen**: «Acciones de correo sugeridas» idem; la etiqueta de bandeja mock siempre visible debajo.

## Archivos relevantes

- `lib/main.dart` — arranque + `initialize`.
- `lib/core/services/local_action_service.dart` — carga, guardado, API pública.
- `lib/core/models/local_action_model.dart` — `toJson` / `fromJson` (sin paquetes extra).
- `lib/shared/widgets/local_action_empty_state.dart` — vacío visual.

## Límites y riesgos

- JSON en claro en almacenamiento local del SO (aceptable para demo).
- Sin deduplicación ni límite de filas.
- `clearLocalActions` es la vía oficial para reset en demos.

## Siguiente paso

Capa de dominio/repositorio y tests con `SharedPreferences.setMockInitialValues` para flujos que llamen a `initialize`.
