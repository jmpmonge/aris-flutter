# Aris v0.29 — Clasificación local de intención

## Resumen

La v0.29 añade una **capa provisional** que clasifica el texto del input de Inicio en categorías (`task`, `note`, `event`, `mail`, `general`, `unknown`) usando **solo reglas por palabras clave en español**. No hay modelo de lenguaje, no hay backend ni APIs externas.

## Comportamiento en la app

1. El usuario escribe en el chat local y envía (igual que v0.28).
2. `IntentClassifierService.classify(text)` evalúa el texto.
3. `ChatService` genera la respuesta simulada de Aris según la intención.
4. En el bloque **RECIENTE**, las burbujas de Aris pueden mostrar un **chip discreto** (TAREA, NOTA, EVENTO, MAIL, GENERAL) cuando hay intención distinta de `unknown`.

## Archivos principales

| Ruta | Rol |
|------|-----|
| `lib/core/models/intent_model.dart` | `IntentType`, `IntentModel` (confianza simulada, texto original, explicación opcional). |
| `lib/core/services/intent_classifier_service.dart` | `classify(String)`: orden fijo tarea → nota → evento → correo; si no hay coincidencia → `general`; vacío → `unknown`. |
| `lib/core/services/chat_service.dart` | Tras cada envío local, clasifica y adjunta `detectedIntent` al mensaje de Aris (salvo `unknown`). |
| `lib/shared/widgets/recent_conversation_card.dart` | Chip visual en la cabecera de la burbuja de Aris. |

## Sustitución futura

- **OpenAI u otro LLM**: sustituir o envolver `IntentClassifierService.classify` por una llamada que devuelva el mismo `IntentModel` (o un DTO que se mapee a él), manteniendo la UI y el contrato del mensaje.
- **Backend**: el servidor puede devolver `type`, `confidence` y metadatos; el cliente solo parsea y rellena `ChatMessageModel.detectedIntent`.

## Límites y riesgos

- **Falsos positivos/negativos**: palabras como “responder” activan correo aunque el contexto sea otro.
- **Prioridad fija**: una frase con “recuérdame” y “mañana” se clasifica como **tarea** (la primera categoría que coincide gana).
- **Confianza**: es un valor **decorativo** derivado de longitud y hash; no es probabilidad real.
- **Persistencia**: la intención vive en memoria con el mensaje de la sesión; no se guarda en base de datos.

## Alcance explícito (no implementado)

No se crean tareas, notas ni eventos reales; no se envía correo; no hay integración de calendario ni OAuth.
