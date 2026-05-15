# Arquitectura de agentes y flujo de trabajo (ARIS v0.22)

## Visión
Este proyecto usa **roles de agente** en Cursor como contrato social: cada rol tiene responsabilidades y límites, de modo que las siguientes fases puedan ejecutarse sin solapamientos caóticos.

Los archivos viven en `.cursor/agents/`:

| Orden | Agente | Función resumida |
|------|--------|------------------|
| 01 | Arquitecto Flutter | Capas, paquetes, navegación, extensibilidad |
| 02 | UI Designer Flutter | Design system, tema Clara/Aris, accesibilidad |
| 03 | Feature Builder | Pantallas y flujos con mocks |
| 04 | Integration Engineer | Contratos reales, iOS/build, App Store readiness |
| 05 | QA & Refactor | Pruebas, riesgos, refactor seguro |

## Skills (cómo ejecutar el trabajo)
Los procedimientos repetibles están en `.cursor/skills/`. Antes de implementar código Flutter, el agente activo debe abrir el skill que corresponda a la tarea (estructura, tema, shell, pantalla, calendario, notas/mail/perfil, asistente, versiones).

## Reglas (límites duros)
`.cursor/rules/` fija lo negociable: documentación mínima, prohibición de backend en fase UI y guía de estilo Clara/Aris.

## Flujo recomendado por fase

### 1. Arquitectura
- Lidera: **01**  
- Entregable: decisión de estructura de `lib/`, router, estrategia de estado; registro en este doc o anexo si hay desvíos.

### 2. Sistema visual
- Lidera: **02**  
- Entregable: tokens, componentes primitivos, tema claro (oscuro si roadmap); revisión por **05** para contraste y tamaños.

### 3. App shell
- Lidera: **01** + **02**  
- Entregable: contenedor de navegación, placeholders de secciones, comportamiento safe area iOS.

### 4. Pantallas simuladas
- Lidera: **03**  
- Apoyo: **02** (consistencia), **01** (límites de capa), **05** (revisiones iterativas).  
- Entregable: features con mocks, estados UX completos listos para demo.

### 5. Revisión
- Lidera: **05**  
- Entregable: lista P0/P1, pruebas añadidas o tickets; propuesta de refactor acotado.

### 6. Futuras integraciones
- Lidera: **04**  
- Entregable: implementaciones reales detrás de los puertos, configuración segura, checklist de permisos iOS y privacidad.

## Principios de gobernanza
- **Un decisor por dimensión**: arquitectura (01), look & feel (02), verificación (05).  
- Los conflictos entre velocidad y deuda se anotan en roadmap, no solo en chat.  
- Integración nunca rompe la UI sin acuerdo explícito documentado.

## Siguiente paso inmediato (estado repo)
La base Flutter existe (`pubspec.yaml`, plataformas generadas, `lib/`). La documentación técnica de capas está en `docs/arquitectura_flutter_v0_22.md` y las notas de versión base en `docs/version_0_22_flutter_base.md`. El orden operativo continúa: **app shell (navegación real y persistencia de tabs) → features mock cableadas**.
