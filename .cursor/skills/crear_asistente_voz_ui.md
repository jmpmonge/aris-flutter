# Skill: Crear asistente voz / UI del asistente

## Cuándo usarlo
Cuando se diseñe la experiencia de **voz o conversación** del asistente Aris, aunque en fases tempranas sea **solo UI y mocks**.

## Objetivo
Interfaces que transmitan escucha, procesamiento y respuesta sin depender todavía de STT/TTS reales.

## Piezas UI típicas
- Indicador de estado: inactivo, escuchando, pensando, hablando (mock con timers).
- Visualización de “última frase” reconocida y respuesta del asistente (texto).
- Controles: tap para iniciar/detener, feedback háptico opcional más adelante.

## Consideraciones iOS
- Micrófono y reconocimiento requerirán permisos y textos `Info.plist` en fase integración; documentar placeholders.
- Evitar grabación simulada confusa: copy claro “demo” si el producto lo permite.

## Accesibilidad
- Alternativa textual a estados puramente visuales (icono animado + label).
- Subtítulos o transcript siempre visibles para usuarios sordos o entornos silenciosos.

## Definición de hecho
- Flujo completo en modo demo sin crash en dispositivo.
- Contrato preparado: `AssistantService` (stub) con métodos `startSession`, `stopSession`, `sendText` según arquitectura.

## No hacer en fase UI
- Integrar SDKs de terceros sin decisión explícita de integration engineer.
- Enviar audio a servidores reales.
