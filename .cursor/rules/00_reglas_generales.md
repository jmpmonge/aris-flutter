# Reglas generales (ARIS Flutter App v0.22)

## Propósito del proyecto
App Flutter **mobile-first**, con **iOS / App Store** como referencia principal, para el asistente personal **Clara** bajo marca **Aris**. El trabajo se organiza por **fases** definidas en `docs/roadmap_v0_22.md`.

## Idioma y comunicación
- Documentación de producto y rules en **español**.
- Código y APIs en **inglés** (convención Flutter/Dart salvo dominio de negocio acordado).

## Alcance y disciplina
- No añadir backend, SDKs de red ni credenciales mientras la fase activa sea solo UI/mocks (véase `01_no_backend_fase_ui.md`).
- Cambios **pequeños y rastreables**; evitar refactors amplios no solicitados.
- Respetar agentes como roles mentales: arquitecto, UI, feature builder, integración, QA (`.cursor/agents/`).

## Calidad mínima
- Pensar siempre en **tres estados**: carga, vacío, error — además del éxito.
- Accesibilidad: targets táctiles, contraste razonable, semantics en componentes no triviales.
- Rendimiento: listas lazy, evitar trabajo pesado en `build`.

## Cursor / IA
- Antes de implementar Flutter en el futuro: leer el skill aplicable en `.cursor/skills/`.
- Tras cambios relevantes: actualizar documentación obligatoria (`02_documentacion_obligatoria.md`).

## Prioridad de decisiones
1. Coherencia con identidad Clara/Aris (`03_estilo_visual_clara.md`).  
2. Experiencia iPhone estrecho.  
3. Extensibilidad para integraciones futuras sin redesplegar todo el front.
