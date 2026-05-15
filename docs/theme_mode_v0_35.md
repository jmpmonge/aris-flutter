# Modo de tema — uso técnico (v0.35)

## API

```dart
// Arranque
await ThemeService.initialize();

// Lectura
final mode = ThemeService.current;
final listenable = ThemeService.themeMode;

// Escritura (persistente)
await ThemeService.setThemeMode(ThemeMode.dark);
```

## Valores persistidos

Clave: `aris_theme_mode_v1`  
Valores: `ThemeMode.name` — `light`, `dark`, `system`.

## Integración UI

- `SettingsScreen` envuelve un `SegmentedButton<ThemeMode>` en `AppCard` con copy contextual.
- `AppThemePreference` centraliza etiquetas ES (`Claro`, `Oscuro`, `Sistema`).

## MaterialApp

```dart
theme: AppTheme.lightTheme,
darkTheme: AppTheme.darkTheme,
themeMode: ThemeService.themeMode.value,
```

Los métodos `AppTheme.light()` / `AppTheme.dark()` siguen existiendo; los getters son alias públicos para cumplir la convención pedida.

## Pruebas

`widget_test` no requiere `initialize()` si la preferencia por defecto es sistema; para tests que dependan de tema fijo, llamar `ThemeService.initialize()` tras `SharedPreferences.setMockInitialValues`.
