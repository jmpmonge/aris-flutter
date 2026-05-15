# Aris v0.28 — Chat input local y conversación simulada

## Objetivo

Dar **comportamiento local** al input inferior de Inicio: envío de mensajes del usuario, respuesta simulada de **Aris** y aviso de voz **sin** backend, **sin** OpenAI y **sin** permisos de micrófono.

## Comportamiento implementado

1. **`lib/core/models/chat_message_model.dart`**  
   - Campos: `id`, `sender` (`aris` | `user`), `text`, `createdAt?`, `kind` (`text` | `suggestion` | `action`).  
   - `toJson` / `fromJson` coherentes con v0.27.

2. **`lib/core/services/chat_service.dart`** (memoria estática en sesión):  
   - `getRecentConversation()` — copia de la cola (inicial + mensajes locales).  
   - `sendLocalMessage(String)` — añade mensaje del usuario + respuesta de `generateMockArisReply`.  
   - `generateMockArisReply(String)` — **texto fijo rotado** (no IA).  
   - `sendVoicePendingNotice()` — inserta mensaje de Aris: *Función de voz pendiente de activar.*  
   - `revision` — `ValueNotifier<int>` para que el Home repinte y haga scroll al final.

3. **`HomeScreen`** (Stateful): escucha `ChatService.revision`, muestra `RecentConversationCard(messages: ChatService.getRecentConversation())`, `ListView` con `ScrollController` y scroll al final tras nuevos mensajes.

4. **`AppNavigationShell`**: `ChatInputBar` con `onSend` → `sendLocalMessage` + limpiar `TextEditingController`; `onMicTap` → `sendVoicePendingNotice`.

5. **`ChatInputBar`**: sin cambios de API; sigue alternando micrófono / enviar según texto (listener del `controller`).

## Límites de la versión

- Los mensajes viven solo en **memoria del proceso** (se pierden al matar la app; hot restart reinicia el buffer tras reabrir).  
- No hay persistencia local (hive/sqflite).  
- No hay streaming ni latencia simulada.  
- **No** grabación, **no** speech-to-text, **no** plugins de voz, **no** permisos.

## Riesgos pendientes

- Cola sin límite: en sesiones largas podría crecer (aceptable en demo).  
- Tests automáticos no cubren aún el flujo envío → dos mensajes nuevos.

## Siguiente paso recomendado

- Persistencia opcional (shared_preferences) solo para última conversación de demo.  
- Capa “repositorio” cuando exista API, sustituyendo el buffer estático.

## Verificación

- `flutter analyze` / `flutter test` OK.  
- Versión: **0.28.0+1** (`pubspec.yaml`, `AppMeta`).
