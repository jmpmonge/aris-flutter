# Skill: Crear app shell (contenedor mobile-first)

## Cuándo usarlo
Fase **app shell**: navegación principal, layout persistente y zona del asistente si es visible globalmente.

## Objetivo
Un contenedor estable donde encajen pantallas simuladas sin reescribir la raíz de la app en cada iteración.

## Decisiones a tomar antes de codificar
1. **Patrón de navegación**: bottom bar + stack (típico móvil), o drawer solo si justificación fuerte en roadmap.
2. **Presencia de Clara**: burbuja flotante, barra inferior, o pantalla dedicada; impacta en safe areas y gestos.
3. **Profundidad**: rutas anidadas por tab; evitar stacks duplicados sin necesidad.

## Piezas típicas del shell
- `AppShell` con `SafeArea` y fondo del tema.
- Host de snackbars / banners de error no intrusivos.
- Área reservada para **modal del asistente** (aunque sea placeholder en fase simulada).

## iOS / App Store
- Respetar `MediaQuery.padding` y regions del notch.
- Considerar gesto de back solo donde Material lo exija; en iOS priorizar botones explícitos en nav bar.

## Definición de hecho
- Navegación entre secciones principales sin perder estado si el roadmap pide preservación en tabs.
- Punto único donde se decide el “header global” vs. header por pantalla.
- Documentado qué partes son mock (p. ej. badge de notificaciones falso).
