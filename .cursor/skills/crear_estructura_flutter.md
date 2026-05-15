# Skill: Crear estructura Flutter (AR v0.22)

## Cuándo usarlo
Al inicializar o reordenar el proyecto Flutter **después** de existir `pubspec.yaml` y `lib/`. No sustituye a la decisión del arquitecto; materializa convenciones acordadas.

## Objetivo
Carpetas predecibles, features acotadas y capa de datos simulada lista para intercambio por integración real.

## Estructura recomendada (referencia)
```
lib/
  app/                 # MaterialApp/CupertinoApp, router, tema
  core/                # utilidades, extensiones, errores, constantes
  design_system/       # tokens, temas, widgets primitivos
  features/
    <feature_name>/
      presentation/    # pantallas, widgets, estados de UI
      domain/          # entidades y puertos (abstract)
      data/            # mocks / futuros datasources
```

## Pasos
1. Confirmar con roadmap la **fase activa** (si aún es solo UI, `data/` solo mocks).
2. Crear `design_system/` antes de la primera pantalla compleja.
3. Por cada feature: carpeta bajo `features/` con los tres subpaquetes anteriores; evitar dependencias cruzadas feature↔feature (usar `core/` o eventos/router).
4. Exportar barrel files (`design_system.dart`) solo si reduce ruido; no abusar.
5. Anotar en `docs/arquitectura_agentes.md` cualquier desviación y el motivo.

## Definición de hecho
- Imports sin ciclos evidentes.
- Punto único de entrada de navegación (router declarado).
- Ningún acceso a red en fase UI.

## Anti-patrones a evitar
- `utils.dart` gigante con lógica de negocio.
- Pantalones “todo en main.dart”.
- Copiar/pegar el mismo `ThemeData` en cada pantalla.
