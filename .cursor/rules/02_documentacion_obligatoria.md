# Regla: Documentación obligatoria

## Principio
Si no está escrito, **no está acordado**. La documentación acompaña al código, no lo sustituye.

## Cuándo actualizar
| Evento | Dónde registrar |
|--------|------------------|
| Nueva convención de carpetas o capas | `docs/arquitectura_agentes.md` y/o `docs/arquitectura_flutter_v0_22.md` |
| Cambio de fase del roadmap | `docs/roadmap_v0_22.md` |
| Base o versión reproducible del proyecto Flutter | `docs/version_0_22_flutter_base.md` (y changelog futuro si se adopta) |
| Design system (tokens / componentes) | `docs/design_system_v0_23.md` + `docs/version_0_23_design_system.md` |
| App shell (tabs, FAB asistente Aris) | `docs/navigation_shell_v0_24.md` + `docs/version_0_24_app_shell.md` |
| Normalización de marca / nombre de producto | `docs/version_0_24_1_rename_to_aris.md` |
| Nuevo mock transversal (auth, usuario, asistente) | Entrada de versión / nota en roadmap |
| Decisión de diseño que afecta a >1 pantalla | Ampliar `03_estilo_visual_aris.md` o anexo corto en `docs/` |
| Lista de dependencias nueva o sensible | Sección “Integración pendiente” (sin secretos) |

## Mínimo por feature simulada
- **Nombre y objetivo** en una frase.
- **Entradas/salidas** del repositorio mock.
- **Estados UX** implementados.
- **Limitaciones** conocidas.

## Versiones
Al preparar un build o cerrar sprint de fase, usar skill `documentar_version.md` y enlazar el commit o tag si existe.

## No hacer
- Copiar pegar dumps de logs largos sin resumen.
- Documentar credenciales o tokens (nunca).
