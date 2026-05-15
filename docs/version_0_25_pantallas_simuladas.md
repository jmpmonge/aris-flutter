# Aris v0.25 — Pantallas simuladas

## Qué incluye esta versión

- **HomeScreen**: estructura vertical heredada de un prototipo HTML funcional (marca → saludo → sugerencia → bloque «Hoy» → bloque «Reciente»), con barra de chat fija y navegación inferior.
- **Pantallas secundarias**: Calendario, Notas, Tareas y Perfil, con datos de demostración coherentes con el diseño.
- **AssistantScreen**: bienvenida y acciones rápidas (solo UI).
- **Estética**: maqueta premium tipo app móvil (fondo cálido, tarjetas muy redondeadas, azul profundo y violeta suave, sombras suaves), no el aspecto frío del prototipo HTML.

## Referencias

| Aspecto | Origen |
|--------|--------|
| Orden y agrupación del Home | Referencia funcional (prototipo HTML previo) |
| Colores, tarjetas y sensación iOS | Referencia estética premium de app de asistente |

## Nombre del producto

El nombre actual del producto es **Aris**. No se utiliza el nombre «Clara» en código, textos ni documentación de esta fase.

## Integraciones

- **No** hay backend, APIs, OpenAI, correo, calendario del sistema ni autenticación.
- Todos los datos son **simulados** con fines de demostración y revisión de UX.

## Pieza central de experiencia

La **barra inferior de chat** (placeholder «Mensaje…», visibilidad de micrófono cuando el campo está vacío y botón enviar cuando hay texto) es un elemento central de la experiencia Aris en Inicio; el envío muestra solo retroalimentación local (por ejemplo SnackBar), sin envío real.

## Versión

Definida en `pubspec.yaml` como **0.25.0+1** (build de demostración).
