# Versión 0.22.0 — base Flutter (fase 1)

## Resumen
Se inicializó el proyecto Flutter en el repositorio con **solo dependencias estándar** (`flutter`, `cupertino_icons`, `flutter_test`, `flutter_lints`). No hay backend, APIs, auth, calendario ni correo reales.

## Contenido funcional
- `main.dart`: punto de entrada mínimo (`WidgetsFlutterBinding`, `runApp`).
- `app.dart`: `MaterialApp` con tema ligero y una pantalla `_BootstrapHome` de marcador.
- `lib/theme/app_theme.dart`: semilla de tema (Material 3) para iterar el design system en fases posteriores.
- `lib/shared/*`: constantes de rutas, breakpoints y tamaño táctil orientativo iOS.
- `lib/features/*`: *shells* de texto mock **no cableados** al `MaterialApp` (solo estructura de carpetas y clases placeholder).

## Mocks activos
- Toda la UI mostrada es estática o texto simulado.
- Los widgets `*FeatureShell` existen para delimitar módulos; no sustituyen pantallas finales.

## Cómo probar (local)
Desde la raíz del proyecto:

```bash
cd /Users/jose/proyectos/aris_flutter_v0.22
flutter pub get
flutter analyze
flutter test
```

**Simulador iOS:**
```bash
open -a Simulator
flutter run -d ios
```

**macOS (opcional, útil para depuración rápida):**
```bash
flutter run -d macos
```

**Chrome (opcional):**
```bash
flutter run -d chrome
```

## Notas de entorno
- En esta máquina el SDK quedó disponible vía Homebrew (`/opt/homebrew/bin/flutter`). Ajusta la ruta si usas FVM o instalación manual.
- Tras clonar en otro equipo: instala Flutter según [flutter.dev](https://docs.flutter.dev/get-started/install) y ejecuta los mismos comandos.

## Próximos hitos (roadmap)
- Fase 2: design system **Aris** sobre `AppTheme`.
- Fase 3: app shell y navegación real hacia los módulos bajo `lib/features/`.
