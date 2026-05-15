# Aris v0.30.1 — Altura máxima de la tarjeta «Reciente» (Inicio)

## Problema detectado

En la pantalla de Inicio, el bloque **RECIENTE** (`RecentConversationCard`) crecía verticalmente con cada mensaje añadido a la conversación mock. Eso rompía el equilibrio respecto al resto de tarjetas y empujaba hacia abajo el contenido de la lista principal (incluida la zona del input de chat en el shell), dificultando mantener una composición tipo app móvil premium.

## Solución aplicada

1. **Constante de diseño**  
   En `lib/theme/app_spacing.dart` se añade `recentConversationBodyMaxHeight` (**220** px lógicos), valor intermedio del rango orientativo 180–240 px para móvil y vistas tipo móvil en web.

2. **Contenedor acotado + scroll interno**  
   En `lib/shared/widgets/recent_conversation_card.dart`, el título «RECIENTE» permanece fijo en la cabecera de la tarjeta y la lista de burbujas se renderiza dentro de un `SizedBox` de altura fija igual a `recentConversationBodyMaxHeight`, con un `ListView.separated` que hace **scroll vertical** cuando el contenido supera esa altura.

3. **Scroll hacia el último mensaje**  
   La tarjeta pasa a ser `StatefulWidget` con un `ScrollController` que, tras nuevos mensajes (cambio de longitud de la lista), desplaza la vista al final en un post-frame, manteniendo el comportamiento esperable de un hilo de chat.

Se mantienen bordes redondeados, sombra, colores del tema, burbujas y chips de intención sin cambios de estilo sustanciales.

## Archivos modificados

| Archivo | Cambio |
|---------|--------|
| `lib/theme/app_spacing.dart` | Nueva constante `recentConversationBodyMaxHeight`. |
| `lib/shared/widgets/recent_conversation_card.dart` | Altura máxima del cuerpo, `ListView` interno, estado + `ScrollController`. |
| `pubspec.yaml` | Versión `0.30.1+1`, descripción actualizada. |
| `lib/core/app_meta.dart` | `versionSemver` `0.30.1`. |

**No** se modificaron servicios de intención, acciones locales, modelos ni lógica de chat más allá del consumo existente de `messages`.

## Decisión sobre altura máxima

- **220 px lógicos** para el área de mensajes (sin contar título ni padding externo de la tarjeta).  
- Proporción alineada con tarjetas compactas de Inicio y dentro del rango solicitado.  
- Si en el futuro se unifica con breakpoints (tablet), el valor puede sustituirse por `LayoutBuilder` o por constantes por `shortestSide`.

## Riesgos pendientes

- Con pocos mensajes, el área de lista sigue ocupando 220 px de alto (hueco visual bajo las burbujas). Aceptado a cambio de un layout estable y predecible. Una evolución posible es `IntrinsicHeight` + `ConstrainedBox(maxHeight:…)` solo si se valida rendimiento y casos borde.
- El scroll interno y el scroll del `ListView` de Inicio pueden anidarse gestualmente; Flutter lo resuelve con competición de gestos habitual en listas anidadas.

## Siguiente paso recomendado

Si el producto exige **altura adaptativa** (crecer hasta un máximo), valorar `LayoutBuilder` o medición del hijo con `min(height, maxHeight)` y prueba en dispositivos pequeños (p. ej. iPhone SE).
