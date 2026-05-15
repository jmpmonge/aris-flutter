# App Shell y navegación — v0.24

## Objetivo
Dar a la app una **estructura realista** de producto móvil: barra inferior persistente, secciones claras y acceso rápido a **Clara**, respetando el design system **v0.23** (sin nuevos tokens salvo uso local en pantallas).

## Arquitectura de navegación

### Contenedor: `AppNavigationShell`
- **StatefulWidget** con `_tabIndex` en `[0..4]`.
- **Cuerpo:** `IndexedStack` con cinco hijos **constantes**:
  1. `HomeScreen`
  2. `CalendarScreen`
  3. `NotesScreen`
  4. `MailScreen`
  5. `ProfileScreen`
- **Por qué `IndexedStack`:** mantiene el **estado y el scroll** de cada pestaña al cambiar de tab (mejor UX que recrear el árbol en cada cambio).
- **Barra inferior:** `AppBottomNavigation` (Material 3 `NavigationBar`) con `AppNavDestination` alineados a los tabs anteriores.
- **Clara:** `AppFloatingActionButton` + `FloatingActionButtonLocation.centerFloat` (centrado sobre la barra, tónica de “asistente en el medio”).
- **Ruta modal:** `Navigator.push` → `AssistantScreen` (stack aparte; botón cerrar vuelve al shell).

### Navegación secundaria
- **Ajustes:** desde **Perfil → Preferencias** → `Navigator.push` a `SettingsScreen` (no está en la barra inferior, según especificación).

## Pantallas creadas (`presentation/`)

| Pantalla | Contenido mínimo (mock) |
|----------|-------------------------|
| `home_screen.dart` | Saludo, resumen del día, cita, tareas, notas |
| `calendar_screen.dart` | Cabecera, `SegmentedButton` Día/Semana/Mes, lista de eventos |
| `notes_screen.dart` | Cabecera, `AppSearchBar` de solo lectura, tarjetas |
| `mail_screen.dart` | Cabecera, segmentos Principal/Social/Promociones, tarjetas tipo inbox |
| `profile_screen.dart` | Tarjeta usuario, filas Cuenta / Preferencias / … |
| `assistant_screen.dart` | Gradiente azul/violeta, cuatro acciones rápidas (snack mock) |
| `settings_screen.dart` | Toggles y listas visuales (sin efecto real) |

## Componentes reutilizados
- `AppScaffold`, `AppBottomNavigation`, `AppFloatingActionButton`, `AppHeader`, `AppCard`, `AppSearchBar`, `SectionTitle`, `SwitchListTile` / `ListTile` según pantalla.
- **No** se duplicó lógica de tarjeta o tipografía: se apoya en `Theme.of(context)` y widgets de `shared`.

## Clara / estética asistente
`AssistantScreen` usa gradiente de **primario Aris → violeta token** (`AppColors.violetSoft`) con tarjetas estándar para mantener coherencia con el resto de la app.

## Límites explícitos (v0.24)
- Ningún `SegmentedButton` o `SwitchListTile` persiste en disco ni llama servicios.
- Mail y calendario **no** leen datos del sistema operativo.
- El FAB **no** graba audio ni abre el teclado multimodal.
- **Deep links / router declarativo** (`go_router`, etc.) **no** están en el alcance: solo `Navigator` imperativo.

## Riesgos / deuda técnica
- **Dos niveles de Scaffold:** shell y algunas pantallas usan solo `SafeArea` + `ListView`; `SettingsScreen` y `AssistantScreen` usan `Scaffold` propio (correcto para AppBar y cierre).
- **Etiquetas repetidas** (“Calendario”, etc.) en tests: distinguir por `Key('tab_*')` en cada tab.
- **Hero del FAB:** `heroTag: 'shell_assistant_fab'` para evitar colisiones si en el futuro hay más FABs.

## Siguiente paso recomendado
1. Introducir **capa mock** (`data/` + interfaces) por feature sin tocar el shell.  
2. Añadir **estados vacío/error** donde aplique (fase 4).  
3. Valorar **router** único cuando existan rutas complejas (detalle mail, nota, evento).

## Referencias
- `docs/version_0_24_app_shell.md`
- `docs/design_system_v0_23.md`
- `docs/roadmap_v0_22.md` (fase 3)
