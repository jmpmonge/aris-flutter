# Aris v0.34 — Revisión UX del flujo completo

## Alcance

Repaso del recorrido **chat (Inicio)** y **formularios por pantalla** tras v0.33, sin nuevas features de producto ni backend. Objetivo: coherencia de copy con **Aris**, hojas de formulario uniformes y tarjetas de acción locales más legibles.

## Flujos revisados

| Vía | Comportamiento |
|-----|----------------|
| **A) Chat** | `ChatService` → `IntentClassifierService` + `LocalActionService.createFromIntent` → misma lista global persistida. |
| **B) Formulario** | `LocalActionFormSheet` → `createTask` / `createNote` / `createEvent` / `createMailAction` → misma lista. |

No se duplicó lógica de negocio: solo presentación y textos.

## Problemas detectados (y criterio)

1. **Formularios**: cuatro llamadas casi idénticas a `showModalBottomSheet` → mantenimiento frágil.
2. **Tarjeta de acción**: el usuario esperaba **chip SIMULADO** explícito además del **estado** (chat vs pendiente vs listo); antes el chip mezclaba sensaciones.
3. **Copy**: faltaba reforzar “Aris” y el carácter local en formularios y en el hint del chat.
4. **Home**: pequeño ajuste de **padding inferior** del `ListView` para más aire antes del bloque de reciente y la barra inferior.

## Cambios realizados

- **`LocalActionModel`**: `operationalStatusLabel` (“Desde chat”, “Pendiente”, “Listo”) para chips legibles sin gritar en mayúsculas.
- **`LocalActionCard`**: chips **Tipo · SIMULADO (tono cálido) · estado operativo · metadatos**; sombras y bordes del tema.
- **`LocalActionFormSheet`**: método interno `_open` unificado (barrier, forma, colores); cabecera `_sheetHeader` con subtítulo *Aris · contenido solo en este dispositivo (simulado)*; títulos “… con Aris”; `SegmentedButton` más compacto; botón mail **Crear acción simulada**.
- **`AppNavigationShell`**: hint del input **Escribe a Aris…**
- **`HomeScreen`**: `padding` inferior ligeramente mayor (`homeSectionSpacing + sm`).
- **`MailScreen`**: sección **Correo con Aris (sugerencias)**.
- Versión **0.34.0+1** y `AppMeta` alineados.

## Componentes tocados (refactor / UX)

- `local_action_form_sheet.dart` (DRY del sheet).
- `local_action_card.dart`, `local_action_model.dart`.
- `home_screen.dart`, `app_navigation_shell.dart`, `mail_screen.dart`.

## Riesgos pendientes

- Muchos chips en **modo compacto** (carrusel de notas) pueden envolver en dos líneas en anchos estrechos (aceptable en demo).
- `statusChipLabel` en el modelo queda como API histórica poco usada en UI; eliminable en limpieza futura si no hay consumidores.

## Siguiente paso recomendado

v0.35: accesibilidad (`Semantics` en acciones de tarjeta, orden de foco en bottom sheet) y prueba en **semillas** de tamaño (SE / tablet estrecha).
