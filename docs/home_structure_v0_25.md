# Estructura del HomeScreen (v0.25)

## Origen de la estructura

El orden vertical obligatorio del Home se toma de una **referencia funcional previa** (prototipo HTML), no de una estructura inventada en esta iteración.

**Efecto visual y componentes** se alinean con una **maqueta premium** de app móvil (fondo crema/cálido, tarjetas pasteleras o blancas, radios grandes, sombras suaves).

## Orden vertical (de arriba abajo)

1. **Header de marca**  
   Texto «Aris» y subtítulo breve (por ejemplo «Organiza tu día con claridad»).

2. **Tarjeta principal de saludo**  
   Saludo contextual simulado (p. ej. «Buenas tardes, José») y resumen del día (p. ej. tareas pendientes). Protagonista visual con degradado o fondo pastel y sombra suave.

3. **Tarjeta de sugerencia**  
   Etiqueta «SUGERENCIA» y texto breve secundario.

4. **Bloque «Hoy»**  
   Título de sección «HOY», con subsecciones **EVENTOS**, **TAREAS** y, si encaja visualmente, **NOTAS** recientes en listas compactas.

5. **Bloque «Reciente»**  
   Mini conversación tipo chat: mensajes de Aris y del usuario; burbujas diferenciadas (usuario alineado a la derecha con azul profundo; Aris a la izquierda sobre fondo cálido; etiquetas «ARIS» / «TÚ» opcionales).

6. **Espacio reservado**  
   Scroll con padding inferior suficiente para que el contenido no quede tapado por la barra de chat y la navegación (la barra de chat la aporta el shell en la pestaña Inicio).

7. **Barra de chat fija** (en el shell, solo Inicio)  
   Campo con placeholder «Mensaje…»; micrófono visible si el texto está vacío; botón enviar si hay texto. Comportamiento local con `TextEditingController`; sin backend.

8. **Navegación inferior** (en el shell)  
   Inicio · Calendario · Notas · Tareas · Perfil.

## Notas técnicas

- Datos simulados en widgets dedicados bajo `lib/shared/widgets/` cuando el patrón se reutiliza.
- Tema claro/oscuro preparado desde `AppTheme`; colores del design system v0.23 se respetan y amplían donde hace falta (p. ej. radios XL).
