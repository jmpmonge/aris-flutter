# Contrato de API — pendiente (v0.27)

## Estado

**No existe contrato definitivo** con backend ni con servicios externos (correo, calendario, IA). Esta versión **no define**:

- URL base, versionado ni prefijos de ruta.
- Esquemas de request/response HTTP.
- Autenticación (tokens, OAuth, etc.).
- Paginación, filtros ni códigos de error de red.

## Qué sí existe hoy

- **Modelos Dart** en `lib/core/models/` con `toJson` / `fromJson` genéricos (uso interno y documentación de forma de datos).
- **Servicios mock** que simulan lecturas locales; son el **único origen de datos** en runtime.

## Principios para la futura integración

1. **No acoplar** pantallas a un cliente HTTP concreto: introducir interfaces en capa `data` o adaptadores cuando exista API.
2. **Validar** campos reales (nullable, formatos de fecha, IDs) contra el contrato OpenAPI/Swagger o equivalente.
3. Sustituir `MockX` por **implementaciones reales** manteniendo firma estable de repositorios si el equipo adopta clean architecture.

## Riesgos si se adelanta integración sin contrato

- Rework de modelos y mappers.
- Inconsistencia entre lo mostrado en UI y persistencia real.

## Siguiente hito sugerido

- Publicar **borrador de API** (aunque sea read-only) o al menos **DTO de lectura** para eventos, tareas y usuario; alinear nombres con `EventModel` / `TaskModel` donde sea posible.
