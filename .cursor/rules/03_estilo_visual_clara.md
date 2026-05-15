# Regla: Estilo visual Clara / Aris

## Personalidad
**Clara** es el asistente: cercano, competente, tranquilizador. **Aris** es el producto: moderno, sobrio, premium sin ser frío.

## Dirección visual (guía para Flutter / iOS)
- **Base**: superficies limpias, mucha respiración, grid implícito en múltiplos de 4/8.
- **Jerarquía**: una acción primaria clara por vista; secundarias discretas.
- **Color**: primario de marca con uso disciplinado; color de acento para “presencia del asistente” solo donde refuerce la conversación o guía.
- **Tipografía**: legibilidad por encima de ornamentación; evitar más de 2–3 tamaños fuertes por pantalla.
- **Iconografía**: línea simple, trazo consistente; preferencia por SF Symbols en mental model iOS aunque se usen sets mixtos en Flutter.

## Tono de microcopy
- Segunda persona (“tú”) cuando el producto hable al usuario.
- Clara usa frases cortas, sin jerga técnica; explica el siguiente paso.
- Errores: humanos, con acción concreta (“Reintentar”, “Revisar conexión” solo cuando exista integración real).

## Motion
- Rápido y funcional; animaciones que refuercen el contexto (aparición de burbuja del asistente), no decoración.

## Accesibilidad
- No depender solo del color para estados.
- Evitar texto sobre imágenes sin scrim.

## Alineación con implementación
- Tokens en `design_system/` (cuando exista código); prohibido esparcir hexadecimales salvo transición documentada.

## Evidencia y evolución
Cambios mayores de identidad requieren actualizar este archivo y el changelog de versión para evitar regresiones silenciosas en UI.
