# Revisión visual v0.26 — Coherencia Aris

## Principios comprobados

| Principio | Implementación |
|-----------|----------------|
| Fondo cálido | `AppTheme` / `ColorScheme` + `scaffoldBackgroundColor` desde `AppColors.canvasLight` (claro) |
| Azul profundo | `ColorScheme.primary` / `AppColors.primaryDeep` en tema |
| Violeta suave | `secondary`, `AppColors.violetSoft` en gradiente del asistente |
| Tarjetas redondeadas | `AppSpacing.radiusLg`, `radiusXl` en tarjetas premium y `CardTheme` |
| Sombras suaves | `ColorScheme.shadow` con alphas bajos; tokens `AppSpacing.shadowBlur*` |
| Mobile-first | `AppScaffold`, safe areas, targets mínimos `minTouchTarget` |

## Cambios de consistencia (v0.26)

1. **Tokens de sombra** — mismos conceptos en saludo, Hoy, sugerencia, Reciente, barra de chat (evita mezclas ad hoc de blur/offset).
2. **Tamaños de icono** — `iconSm` / `iconMd` / `iconLg` / `iconFab` en lugar de literales (`18`, `22`, `24`, `28`).
3. **Espaciado inferior** — `fabStackClearance` para listas cuando hay FAB flotante; el Home **no** usa padding inferior extra (el `body` del `Scaffold` termina encima del chat y la nav).
4. **Layout** — ancho de columna de hora en calendario y avatar de perfil nombrados en `AppSpacing`.
5. **Versión visible** — `AppMeta.userVisibleVersionLine` para no desincronizar Perfil respecto al `pubspec`.

## Colores hardcodeados que se mantienen (justificados)

- `Colors.transparent` en `AppBar` extendido del asistente y fondos `InkWell` (`QuickActionCard`) — idiomático en Material; no añade paleta nueva.
- Opacidades tipo `0.9`, `0.35` sobre `scheme.*` — ajuste fino de jerarquía; alternativa futura: extender `AppColors` con variantes documentadas.

## Referencias cruzadas

- Detalle de archivos y riesgos: [version_0_26_qa_refactor.md](./version_0_26_qa_refactor.md)
- Design system base: [design_system_v0_23.md](./design_system_v0_23.md)

## TODO visual v0.27 (resumen)

- Revisión de contraste en **AssistantScreen** (texto claro sobre gradiente + tarjetas blancas).
- Unificar **elevation** de `Card` vs `DecoratedBox` custom si se desea una sola familia de sombras.
- Valorar **animaciones** de transición Inicio ↔ Asistente (opcional, sin scope v0.26).
