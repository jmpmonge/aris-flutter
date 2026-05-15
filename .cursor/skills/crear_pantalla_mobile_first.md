# Skill: Crear pantalla mobile-first

## Cuándo usarlo
Cada nueva pantalla en fase **pantallas simuladas** o cuando se divide una vista compleja.

## Objetivo
Layouts legibles en **ancho estrecho primero**; tablet/desktop como mejora opcional si el roadmap lo pide.

## Plantilla mental
1. **Carga inicial**: skeleton o spinner según design system; evitar pantalla en blanco >200 ms percibidos.
2. **Vacío**: ilustración ligera o icono + copy Clara/Aris (tono cercano, no técnico).
3. **Error**: mensaje claro + acción de reintento (aunque el reintento sea mock).
4. **Éxito**: lista/formulario según caso; mantener scroll único por eje cuando sea posible.

## Reglas de layout
- `ListView`/`CustomScrollView` para contenido largo; cuidado con `TextField` y teclado (`resizeToAvoidBottomInset`).
- Separar cabecera fija solo si UX lo requiere; si no, sliver app bar.
- Botones primarios accesibles al pulgar en móvil (zona inferior o FAB según patrón del shell).

## Datos
- Repositorio mock inyectado o localizado en capa `data/` de la feature.
- No IDs mágicos en la UI: usar view models o DTOs de presentación.

## Definición de hecho
- Funciona en iPhone pequeño de referencia (simulador) sin overflow amarillo.
- Estados cubiertos o explícitamente marcados como fuera de alcance en el roadmap.
