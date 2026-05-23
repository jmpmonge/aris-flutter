import 'dart:ui';

/// Escala 4/8 mobile-first; radios y objetivo táctil tipo iOS (~44 logical px).
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 18;

  /// Esquina “cola” en burbujas de chat.
  static const double radiusTail = 4;

  /// Tarjetas premium tipo home (muy redondeadas).
  static const double radiusXl = 24;

  /// Iconos en listas compactas / bullets.
  static const double iconSm = 18;

  /// Iconos en tarjetas de acción y chips leading.
  static const double iconMd = 24;

  /// Iconos destacados (saludo, hero).
  static const double iconLg = 28;

  /// Botón circular compacto (enviar en barra de chat).
  static const double iconFab = 22;

  /// Columna de hora en filas tipo agenda.
  static const double calendarTimeColumnWidth = 52;

  static const double profileAvatarRadius = 28;

  /// Altura fija de la franja horizontal de chips en Notas.
  static const double quickChipsStripHeight = 40;

  /// Ancho máximo de burbuja de chat en bloque Reciente.
  static const double chatBubbleMaxWidth = 320;

  /// Altura máxima del área de mensajes dentro de la tarjeta **RECIENTE** (Inicio);
  /// el exceso hace scroll interno. Valor intermedio del rango 180–240 px lógicos.
  static const double recentConversationBodyMaxHeight = 220;

  /// Separación inferior en listas cuando hay FAB flotante centrado.
  static const double fabStackClearance = 100;

  /// Extra bajo la rejilla Semana (FAB centerFloat + nav; v0.49.4).
  static const double calendarWeekBottomClearanceExtra = 48;

  /// Espacio vertical **uniforme** entre bloques de Inicio (cabecera, tarjetas, reciente)
  /// y respiro final antes de la barra de chat. Valor intermedio (16–24) para ritmo premium.
  static const double homeSectionSpacing = 20;

  /// Inicio v0.48.2 — margen lateral global referencia Structured (iPhone ~393).
  /// Fecha fija superior y tarjetas (SUGERENCIA, HOY, CHAT) comparten este inset (v0.48.36).
  static const double homePageMarginH = 18;

  /// Respiro superior antes de fecha+avatar en Home (v0.48.37).
  static const double homeHeaderTopGap = 6;

  /// Margen superior fecha fija Home (v0.49.31: −6 px respecto a v0.49.30).
  static const double homeFixedDateTopGap = 10;

  /// Respiro bajo la línea fecha/config, antes del scroll (10–16 px).
  static const double homeFixedDateMinPadding = 10;

  /// Fecha fija → bloque saludo «Hola, …» (v0.49.31: compacto).
  static const double homeFixedDateToEphemeralGap = 0;

  /// Altura reservada del bloque saludo expandido (v0.49.53).
  /// Solo texto de saludo; el clima se posiciona en Stack aparte.
  static const double homeGreetingSlotHeight = 38;

  /// Respiro bajo cabecera viva con saludo visible (v0.49.53).
  static const double homeLiveHeaderBottomWithGreeting = 7;

  /// Respiro bajo cabecera compacta sin saludo (v0.49.53).
  static const double homeLiveHeaderBottomCompact = 9;

  /// ListView → HOY mientras el saludo ocupa cabecera (v0.49.53).
  static const double homeGreetingToHoyGapVisible = 6;

  /// Fecha fija → HOY cuando el saludo temporal está oculto (v0.49.53).
  static const double homeFixedDateToHoyWhenGreetingHidden = 8;

  /// Inset izquierdo del texto de fecha fija (margen pantalla + sangría; v0.48.37).
  static const double homeFixedDateLeftInsetH =
      homePageMarginH + homeCardPadding;

  /// Mínimo en zonas muy densas (no sustituye al global salvo casos puntuales).
  static const double homePageMarginDenseH = 16;

  /// Separación vertical entre bloques de Inicio.
  static const double homeSectionGap = 12;

  /// Máxima entre bloques principales (evita > 20 px de aire).
  static const double homeSectionGapMax = 16;

  /// Hueco superior de Aris al subir con scroll (0 = pegado al borde útil).
  static const double homeArisScrollTopGap = 0;

  /// Respiro bajo el último ítem del ListView (encima del dock fijo).
  static const double homeScrollBottomBreathing = 12;

  /// Aire entre la tarjeta Aris (scroll) y el input fijo (v0.48.49).
  static const double homeArisCardToInputGap = 16;

  /// Tras cabecera → primera tarjeta (Greeting).
  static const double homeHeaderToGreetingGap = 14;

  /// Tarjeta superior descartable → tarjeta HOY (v0.48.32).
  static const double homeTopInsightToHoyGap = 17;

  /// Fecha compacta → tarjeta HOY tras descartar insight (v0.48.32).
  static const double homeCompactDateToHoyGap = 8;

  /// Fecha fija → tarjeta SUGERENCIA (v0.48.34).
  static const double homeFixedDateToSuggestionGap = 9;

  /// SUGERENCIA visible → tarjeta HOY (v0.48.34).
  static const double homeSuggestionToHoyGap = 15;

  /// Fecha fija → HOY cuando SUGERENCIA está oculta (v0.48.34).
  static const double homeFixedDateToHoyGapCollapsed = 11;

  /// Saludo temporal → tarjeta HOY (v0.48.41).
  static const double homeGreetingToHoyGap = 13;

  /// Hueco mínimo tras colapsar saludo temporal (v0.48.41).
  static const double homeGreetingCollapsedGap = 0;

  /// Padding vertical zona hover saludo temporal (v0.48.41).
  static const double homeGreetingInteractivePadV = 6;

  /// Radio tarjetas Home (Structured).
  static const double homeCardRadius = 22;

  /// Radios internos / chapas.
  static const double homeCardRadiusInner = 18;

  static const double homeCardPadding = 14;

  /// Tabulado óptico cabecera viva Home (v0.49.49): punto medio entre margen
  /// exterior de tarjeta y padding interno — simétrico izquierda/derecha.
  static const double homeHeaderHorizontalInset =
      homePageMarginH + homeCardPadding / 2;

  static const double homeCardPaddingCompact = 12;

  /// Cabeceras de tarjetas Home — **HOY**, **CHAT CON ARIS** (v0.48.29 compacto real).
  /// Altura visual ~34 px: padding 4 + fila ~26 (sin `minHeight` que fuerce 38–44 px).
  static const double homeCardHeaderInkPaddingH = 10;
  static const double homeCardHeaderInkPaddingV = 4;
  static const double homeCardHeaderInkBorderRadius = 13;
  static const double homeCardHeaderIconSize = 22;
  static const double homeCardHeaderIconTitleGap = 8;
  /// Referencia documental; la fila usa altura intrínseca (no `ConstrainedBox` con este valor).
  static const double homeCardHeaderVisualHeight = 34;
  static const double homeCardHeaderChevronSize = 22;
  static const double homeCardHeaderChevronBox = 26;

  /// Distancia cabecera → contenido en tarjetas Home (HOY, CHAT CON ARIS; v0.48.29).
  static const double homeCardHeaderToContentGap = 5;

  /// Microencabezado **TAREAS** dentro de [TodaySummaryCard] (v0.48.28).
  static const double homeTasksSectionIconSize = 19;
  static const double homeTasksSectionIconTitleGap = 8;
  static const double homeTasksSectionHeaderLeftInset = 12;
  static const double homeTasksSectionDividerToHeaderGap = 8;
  static const double homeTasksSectionHeaderToFirstTaskGap = 6;
  static const double homeTasksSectionNoDividerToHeaderGap = 8;

  /// Barra inferior tipo cápsula (v0.48.4: ~56 px + padding interno → ~60 px visuales).
  static const double homeNavBarHeight = 56;

  static const double homeNavBarRadius = 26;

  static const double homeNavBarHorizontalPadding = 12;

  static const double homeNavIconSize = 23;

  /// Altura fila barra “Escribe a Aris…”.
  static const double homeChatInputHeight = 52;

  static const double homeChatMicButtonSize = 48;

  /// FAB asistente (shell).
  static const double homeFabDiameter = 64;

  static const double homeFabIconSize = 34;

  /// Iconos de fila en listas Home (HOY, etc.).
  static const double homeRowIconSize = 21;

  /// Sombra muy suave para tarjetas Home (casi planas).
  static const double shadowBlurHomeCard = 5;
  static const Offset shadowOffsetHomeCard = Offset(0, 2);

  static const double shadowBlurHero = 20;
  static const Offset shadowOffsetHero = Offset(0, 8);

  static const double shadowBlurCard = 16;
  static const Offset shadowOffsetCard = Offset(0, 6);

  static const double shadowBlurSoft = 12;
  static const Offset shadowOffsetSoft = Offset(0, 4);

  static const double shadowBlurChat = 14;
  static const Offset shadowOffsetChat = Offset(0, 5);

  static const double shadowBlurLift = 10;
  static const Offset shadowOffsetLift = Offset(0, 3);

  static const double shadowBlurBar = 8;
  static const Offset shadowOffsetBar = Offset(0, -2);

  /// Elevación Material para sombras suaves en tarjetas.
  static const double cardElevationLight = 3;
  static const double cardElevationDark = 1;

  /// Área mínima recomendada para targets (Human Interface Guidelines).
  static const double minTouchTarget = 44;

  /// Nota amplia — valores locales de bloque (gaps entre bloques: [NoteBodyBlockSpacing]).
  static const double noteBodyTitleToFirstBlock = 6;
  static const double noteBodyTableCellPadV = 5;
  /// Zona tap solo si la tabla no tiene bloque siguiente (evita sumar con el separador).
  static const double noteBodyTableTapBelow = 8;
}
