# aris_flutter_v0_22

Proyecto **Flutter** del producto **Aris** (asistente personal / agenda, mobile-first, orientado a iOS).

## Versión actual

**Tag:** `v0.49.85`

Calendario Día, Semana y Mes con despliegue fiable y tarjetas coherentes. Detalle en `docs/versions/v0.49.85_calendario_semana_mes_toggle_y_subtitulo_unificado.md`.

## Desarrollo

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

Build web release:

```bash
flutter clean
flutter pub get
dart analyze
flutter build web --release
```

## Documentación

- Índice de docs: `docs/README.md`
- Versión actual v0.49.85: `docs/versions/v0.49.85_calendario_semana_mes_toggle_y_subtitulo_unificado.md`
- Cierre frontend v0.49.78: `docs/versions/v0.49.78_cierre_frontend_premium_press.md`
- Roadmap y fases: `docs/roadmap_v0_22.md`
- Diseño: `docs/design_system_v0_23.md`
- Navegación: `docs/navigation_shell_v0_24.md`
- Normalización de nombre: `docs/version_0_24_1_rename_to_aris.md`

Recursos generales de Flutter: [documentación oficial](https://docs.flutter.dev/).
