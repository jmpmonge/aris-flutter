# Roadmap ARIS Flutter App v0.22

## Contexto
Producto **mobile-first** orientado a **iOS / App Store**, con identidad **Clara** (asistente) y marca **Aris**. Esta versión **v0.22** prioriza demo creíble con **datos simulados** antes de integraciones productivas.

## Fases (orden obligatorio para minimizar retrabajo)

### Fase 1 — Arquitectura
**Objetivo:** Proyecto Flutter inicializado con capas base y convención de features.  
**Entregables:** Estructura `lib/` (`app`, `theme`, `shared`, `features`), constantes de rutas (`AppRoutes`), documentación en `docs/arquitectura_flutter_v0_22.md` y `docs/version_0_22_flutter_base.md`.  
**Agente principal:** Arquitecto Flutter (01).  
**Criterio de salida:** `flutter analyze`, `flutter test` y `flutter run` locales en verde; sin pantallas finales complejas; sin integraciones; mocks solo como texto o shells no cableados.

### Fase 2 — Sistema visual
**Objetivo:** Design system alineado con Clara/Aris.  
**Entregables:** Tokens, tema, componentes primitivos, guía breve de uso.  
**Agente principal:** UI Designer Flutter (02).  
**Criterio de salida:** Pantalla “galería interna” o Storybook-like **opcional**; al menos uso en 1 pantalla placeholder.

### Fase 3 — App shell
**Objetivo:** Contenedor de app con navegación principal estable.  
**Entregables:** Tabs/stack, tratamiento de safe area, área reservada para asistente si aplica.  
**Agentes:** Arquitecto (01) + UI (02).  
**Criterio de salida:** Se puede navegar entre secciones vacías sin reconstruir la raíz.

### Fase 4 — Pantallas simuladas
**Objetivo:** Flujos demostrables con mocks.  
**Bloques previstos (ajustables):**  
- Calendario visual (skill dedicada)  
- Notas / mail / perfil (paquete coherente)  
- UI de asistente (voz/conversación simulada)  
**Agente principal:** Feature Builder (03).  
**Criterio de salida:** Cada bloque tiene estados carga/vacío/error/éxito o justificación documentada; **sin red real** (regla `01_no_backend_fase_ui.md`).

### Fase 5 — Revisión
**Objetivo:** Consolidar calidad y reducir deuda antes de integrar.  
**Entregables:** Informe QA, lista de bugs, tests mínimos en flujos críticos.  
**Agente principal:** QA & Refactor (05).  
**Criterio de salida:** Build reproducible; entrada de versión con mocks listados (`documentar_version`).

### Fase 6 — Futuras integraciones
**Objetivo:** Sustituir mocks por servicios reales y preparar App Store.  
**Entregables:** Clientes API/auth, persistencia, permisos iOS, pipeline de build si aplica.  
**Agente principal:** Integration Engineer (04).  
**Criterio de salida:** Interfaces de usuario sin cambios sustantivos al sustituir mocks; documentación de configuración sin secretos en repo.

## Dependencias entre fases
```
1 Arquitectura → 2 Sistema visual → 3 App shell → 4 Pantallas simuladas
                                                      ↓
                                               5 Revisión
                                                      ↓
                                               6 Integraciones
```

## Estado actual
- [x] Fase 1 completada (2026-05-15) — base Flutter + estructura modular inicial.  
- [x] Fase 2 completada (2026-05-15) — design system Clara/Aris (`docs/design_system_v0_23.md`, `docs/version_0_23_design_system.md`).  
- [ ] Fase 3 completada  
- [ ] Fase 4 completada  
- [ ] Fase 5 completada  
- [ ] Fase 6 completada  

*Añadir fecha/notas al cerrar cada fase siguiente.*

## Riesgos explícitos
- **Sobreedición de mocks:** mantener lista viva de qué es falso hasta integración.  
- **Scope creep en asistente:** acotar v0.22 a demo creíble, no producto de voz completo.  
- **iOS permissions:** cada permiso debe corresponder a feature real en roadmap de integración.

## Nota de alcance v0.22
Objetivo: *demo premium coherente con Clara/Aris*, no paridad con un backend completo. El roadmap puede bifurcar en v0.23+ incrementales según resultados de la fase 5.
