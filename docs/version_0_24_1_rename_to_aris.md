# Versión 0.24.1 — Normalización del nombre del producto a **Aris**

## Objetivo
Unificar la denominación operativa del producto bajo el nombre **Aris**. Cualquier nombre interno previo del asistente queda **obsoleto** para copy, código y docs operativos (véase nota histórica en la regla de estilo).

## Decisiones
- **Producto y asistente en UI:** solo **Aris** (textos de pantalla, tooltips, cabeceras, ajustes).
- **Regla de estilo:** archivo renombrado a `.cursor/rules/03_estilo_visual_aris.md` (contenido actualizado + nota histórica al inicio).
- **Sin cambios** de arquitectura, diseño visual (tokens/hex), ni dependencias.

## Archivos tocados (resumen)
| Área | Cambios |
|------|---------|
| Reglas Cursor | Nuevo `03_estilo_visual_aris.md`; eliminada la regla de estilo previa cuyo nombre contenía el término obsoleto; referencias actualizadas en `00`, `02` |
| Agentes | `01_arquitecto_flutter.md`, `02_ui_designer_flutter.md` |
| Skills | `crear_*` (design system, shell, pantalla, asistente voz, notas/mail/perfil) |
| `lib/` | `assistant_screen.dart`, `settings_screen.dart`, `app_navigation_shell.dart`, `app_card.dart`, `empty_state_card.dart`, `assistant_feature_shell.dart` |
| `docs/` | `arquitectura_agentes.md`, `arquitectura_flutter_v0_22.md`, `design_system_v0_23.md`, `navigation_shell_v0_24.md`, `roadmap_v0_22.md`, `version_0_22_flutter_base.md`, `version_0_24_app_shell.md`, `version_0_24_1_rename_to_aris.md` |
| Raíz | `README.md`, `pubspec.yaml` (descripción + `0.24.1+1`) |

## Referencia histórica intencionada
- **`.cursor/rules/03_estilo_visual_aris.md`**: bloque *Nota histórica* al inicio del archivo (único lugar de reglas donde se cita el nombre interno previo del asistente, marcado como obsoleto).
- **Este documento** registra la decisión de normalización; no reintroduce ese nombre en la app ni en otros entregables.

## Verificación
Tras el cambio, no debe aparecer el nombre obsoleto en `lib/`, `README.md`, agentes, skills ni reglas **salvo** la nota histórica citada arriba. Ejecutar:

```bash
flutter analyze
flutter test
```

## Siguiente paso
Continuar **fase 4** (pantallas simuladas en profundidad, mocks con interfaces) sobre la base del **App Shell v0.24** y el branding **Aris**.
