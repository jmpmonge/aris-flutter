# Revisión de flujo UX — v0.34

## Narrativa unificada

Tanto el **mensaje en Inicio** como el **+ / formulario** crean filas en `LocalActionService`; las pantallas solo **leen** y muestran. El usuario puede alternar libremente entre vías sin comportamientos distintos.

## Textos y marca

- Producto **Aris** en hints, títulos de formulario y sección de mail.
- No se introduce “Clara”.
- Estados visibles: **SIMULADO** (naturaleza demo) + **Desde chat / Pendiente / Listo** (flujo).

## Home

- Sin nuevas tarjetas: solo padding fino para ritmo vertical.
- Reciente sigue con altura máxima definida en v0.30.1.
- Input: hint explícito hacia Aris.

## Formularios

- Un solo configurador de modal bottom sheet.
- Cancelar siempre visible.
- Validación mínima: título (o asunto en correo) obligatorio.

## Tarjeta local

- Menos “panel corporativo”: jerarquía tipográfica conservada, chips diferenciados por color (tipo / simulado / estado).
- Completar y eliminar solo en tarjeta **no compacta** (listados principales).

## Navegación

- Sin cambios estructurales: IndexedStack + barra inferior; chat solo en Inicio.
- Asistente y Mail (desde Perfil) intactos.

## Límites

- Sin backend, APIs, OpenAI, calendario o correo reales.
- Sin dependencias nuevas.

## Próximo paso

Tests de widget ligeros sobre apertura/cierre de un formulario y verificación de hint del `ChatInputBar`.
