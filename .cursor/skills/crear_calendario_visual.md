# Skill: Crear calendario visual

## Cuándo usarlo
Feature de agenda/timeline asociada al asistente (planificación, recordatorios visuales) en fase simulada.

## Objetivo
Vista **escaneable** en móvil: día/semana según alcance v0.22, con eventos falsos pero realistas.

## Opciones de implementación
1. **Custom painter / layout propio**: máximo control, más coste.
2. **Lista + sticky headers** por día: rápido, muy mobile-first.
3. **Paquete de terceros**: solo si licencia y peso están justificados en arquitectura.

## Contenido de evento (mock)
- título corto, hora, color categoría, indicador de “asistente sugirió”.
- toque: detalle modal o pantalla secundaria.

## Interacciones mínimas
- Cambio de día (chevron o date picker compacto iOS).
- Scroll suave a “ahora” si la vista es del día actual.

## Definición de hecho
- Performance aceptable con ≥30 eventos ficticios (builder lazy).
- Accesibilidad: lectura de fecha y eventos en orden lógico con VoiceOver.

## Futuro cableado
Sustituir fuente de eventos por API/calendario nativo sin cambiar diseño de tarjeta; solo mapping en `data/`.
