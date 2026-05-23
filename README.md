# aris_flutter_v0_22

Proyecto **Flutter** del producto **Aris** (asistente personal / agenda, mobile-first, orientado a iOS).

## Versión actual — frontend congelado

**Tag:** `v0.49.78`

Cliente UI cerrado en esta versión. Home, Calendario, Tareas, Notas y shell de navegación no se modificarán en esta fase salvo correcciones críticas. Detalle en `docs/versions/v0.49.78_cierre_frontend_premium_press.md`.

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

- Cierre frontend v0.49.78: `docs/versions/v0.49.78_cierre_frontend_premium_press.md`
- Roadmap y fases: `docs/roadmap_v0_22.md`
- Diseño: `docs/design_system_v0_23.md`
- Navegación: `docs/navigation_shell_v0_24.md`
- Normalización de nombre: `docs/version_0_24_1_rename_to_aris.md`

Recursos generales de Flutter: [documentación oficial](https://docs.flutter.dev/).
