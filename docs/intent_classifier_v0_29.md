# Clasificador de intención local (v0.29)

## Qué intenciones se detectan

| Tipo | Significado | Etiqueta en UI |
|------|-------------|----------------|
| `task` | Posible tarea / recordatorio | TAREA |
| `note` | Nota o idea rápida | NOTA |
| `event` | Cita o referencia temporal / calendario | EVENTO |
| `mail` | Correo electrónico | MAIL |
| `general` | Texto sin palabras clave de las categorías anteriores | GENERAL |
| `unknown` | Entrada vacía (no se muestra chip) | — |

## Reglas (palabras clave)

El texto se normaliza a minúsculas. La **primera categoría** de la lista siguiente con alguna subcadena coincidente gana.

1. **Tarea** (`task`): `recuérdame`, `recuerdame`, `tengo que`, `pendiente`, `hacer`, `llamar`, `comprar`.
2. **Nota** (`note`): `nota`, `apunta`, `guardar idea`, `idea`, `anotar`.
3. **Evento** (`event`): `mañana`, `manana`, `hoy a`, `reunión`, `reunion`, `cita`, `calendario`, `a las`.
4. **Correo** (`mail`): `correo`, `email`, `mail`, `responder`, `enviar correo`.
5. Si ninguna coincide → **`general`**.

Si el texto tras `trim()` está vacío → **`unknown`**.

## Confianza simulada

`IntentModel.confidence` está entre `0.0` y `1.0` y se calcula con una fórmula local (longitud de la clave y un pequeño “jitter” derivado del hash del texto). **No representa** una salida de un clasificador entrenado.

## Respuestas simuladas de Aris

Definidas en `ChatService._replyForIntent` (textos fijos por tipo). Sirven para demostrar el flujo hasta existir backend o LLM.

## Tecnología

- **Sin paquetes nuevos** para clasificación.
- **Sin IA real**, sin red.
- **Capa provisional**: pensada para reemplazarse por inferencia remota o local más sofisticada sin cambiar el modelo `IntentModel` si se mantiene el mismo esquema.

## Riesgos operativos

- Multidioma limitado (listas en español).
- Reglas frágiles frente a variaciones (“mandar mail” sin “mail” puede caer en `general`).
- Posible confusión del usuario si la etiqueta no coincide con su intención; conviene documentar en release notes que es **demo**.
