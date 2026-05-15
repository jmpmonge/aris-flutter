# Diseño — modo oscuro Aris (v0.35)

## Intención

Modo oscuro **legible y premium**: base **azul‑gris** (no gris neutro plano), tarjetas una rampa más clara que el lienzo, texto principal casi blanco azulado y secundarios atenuados.

## Tokens (`AppColors`)

- **Lienzo (`canvasDark`)**: `#121820` — profundo, ligeramente azulado.
- **Superficie (`surfaceDark`)**: `#1A222C` — capa principal.
- **Contenedores elevados**: `#242E3A` / `#2F3A48` — jerarquía sutil.
- **Texto**: `#E8EEF4` principal, `#B4BCC6` secundario, `#858D98` terciario.
- **Contornos**: `#3D4A5C` / `#2A3440` — separación sin bordes duros.
- **Acentos**: el `ColorScheme.dark` mantiene primario azul claro y violeta como secundario para contraste legible.

## Sombras

- Alpha `0.35` en sombra del esquema oscuro para halos más limpios.

## Pantallas con tratamiento extra

- **Asistente**: gradiente en oscuro usa `primary` → `primaryContainer` → `secondary` del tema.
- **QuickActionCard**: `Material` con color `surface` opacidad 0 para respetar el gradiente.

## Pendientes

- Auditoría de contraste AA en todos los chips y estados deshabilitados.
- Tono de snackbars / bottom sheets en oscuro (heredan `ColorScheme`).
