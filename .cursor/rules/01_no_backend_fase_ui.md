# Regla: Sin backend en fase UI / simulación

## Ámbito
Aplica mientras el roadmap marque fases **sistema visual**, **app shell** o **pantallas simuladas** como dependientes solo de UI y dominio mockeado.

## Qué está permitido
- Datos **hardcoded**, generadores locales, `Future.delayed` y repos en memoria.
- Contratos (`abstract class` / interfaces) que definan lo que luego implementará integración.
- Simulación de latencia y errores **controlados** para UX.

## Qué está prohibido sin fase explícita de integración
- Peticiones HTTP/WebSocket reales, Firebase/Supabase/AWS u otros BaaS.
- OAuth, almacenamiento de tokens reales, Keychain con secretos productivos.
- Envío de audio, ubicación o PII a terceros.
- Añadir claves API, `.env` con secretos o certificados al repositorio.

## Cómo dejar el código listo para el futuro
- La UI depende de **puertos** (repositorios/servicios) no de implementaciones concretas.
- Comentarios mínimos `// INTEGRATION:` donde el mock deba sustituirse (sin párrafos).
- Listar mocks activos en documentación de versión al cerrar hitos (`documentar_version.md`).

## Salida de esta fase
Checklist en `docs/roadmap_v0_22.md`: “UI demostrable sin red” marcada antes de abrir trabajo de integración.
