# Skill: Documentar versión (v0.22+)

## Cuándo usarlo
Al cerrar una fase del roadmap, al preparar build de prueba o al etiquetar un hito interno.

## Objetivo
Traza clara de **qué** funcionaba, **qué** era mock y **qué** riesgos quedaban, alineado con App Store TestFlight si aplica.

## Contenido mínimo por versión
1. **Número y fecha** (semver interno del proyecto).
2. **Alcance**: features tocadas vs. fuera de alcance.
3. **Mocks**: lista de datos o servicios no reales.
4. **Known issues** priorizados.
5. **Instalación**: rama/commit, comando `flutter` relevante, versión mínima iOS.

## Ubicación sugerida
- `CHANGELOG.md` o `docs/releases/` cuando el equipo lo defina.
- Actualizar `docs/roadmap_v0_22.md` marcando fases completadas.

## App Store / privacidad (recordatorio)
- Sin afirmar permisos que la app aún no usa.
- Preparar texto de “Qué hay de nuevo” coherente con el changelog técnico.

## Definición de hecho
Cualquier miembro del equipo puede reconstruir el estado del producto leyendo solo la entrada de versión, sin preguntar en chat.
