# Skill: Crear design system (Aris)

## Cuándo usarlo
Fase **sistema visual** y antes de construir más de 2–3 pantallas con estilo propio.

## Objetivo
Centralizar tokens y componentes para que **Aris** se sienta coherente en iOS.

## Contenido mínimo del design system
1. **Color**: primario, secundario, superficies, texto (alto/bajo énfasis), estados (éxito, aviso, error), “accent asistente” separado del primario de marca si mejora legibilidad.
2. **Tipografía**: familia del sistema SF en iOS vía `Theme`; escala (display / título / cuerpo / etiqueta) con alturas de línea definidas.
3. **Espaciado**: `xxs…xl` en valores consistentes (4/8 base).
4. **Forma**: radios de tarjeta, botones, chips; sombras mínimas o ninguna si se busca look nativo.
5. **Motion**: duraciones (150–300 ms) y curvas estándar.

## Implementación Flutter (guía)
- Un `ThemeExtension` o clases de tokens inmutables (`AppColors`, `AppSpacing`) consumidas por `ThemeData`/`CupertinoThemeData` según arquitectura.
- Widgets primitivos: `AppScaffold`, `AppPrimaryButton`, `SectionHeader`, `AssistantBubble` (nombre tentativo).
- Documentar en comentario breve **por qué** un componente existe (evitar duplicados).

## Accesibilidad
- Contraste mínimo WCAG AA en textos principales.
- Tamaño mínimo de área táctil ~44 pt lógicos.

## Definición de hecho
- Tema claro operativo; oscuro solo si roadmap lo incluye.
- Lista de componentes con variantes y estados (pressed, disabled).
- Pantallas existentes migradas para **no** hardcodear `Color(0xFF...)` fuera de tokens.
