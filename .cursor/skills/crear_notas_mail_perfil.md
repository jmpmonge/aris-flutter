# Skill: Crear notas, mail y perfil (paquete UX coherente)

## Cuándo usarlo
Cuando el roadmap incluya **productividad personal** simulada: notas rápidas, bandeja tipo mail, perfil de usuario.

## Objetivo
Tres experiencias que se sientan del mismo producto Aris, reutilizando el design system y el tono Clara.

## Notas (simulado)
- Editor simple multilinea; lista con títulos derivados de primera línea.
- Estados: lista vacía, borrador, “sincronización” falsa con delay.
- Acciones: archivar/eliminar con undo local (solo memoria).

## Mail (simulado)
- Lista tipo inbox con remitente, asunto, snippet, estado leído.
- Detalle con cuerpo estático o generado localmente.
- **No** intentar protocolos reales (IMAP/SMTP) en fase UI.

## Perfil
- Avatar placeholder, nombre, preferencias toggles (mock), enlaces legales futuros como texto estático si aplica.
- Sección “Asistente Clara”: tono, sugerencias, o límites (todo simulado).

## Definición de hecho
- Navegación clara vuelta atrás en subpantallas.
- Copys alineados con regla `03_estilo_visual_clara.md` (tono, no jerga técnica al usuario).
- Lista explícita de permisos iOS **no** solicitados aún (para integración posterior).
