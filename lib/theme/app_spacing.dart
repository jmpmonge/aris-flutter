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

  /// Espacio vertical **uniforme** entre bloques de Inicio (cabecera, tarjetas, reciente)
  /// y respiro final antes de la barra de chat. Valor intermedio (16–24) para ritmo premium.
  static const double homeSectionSpacing = 20;

  /// Inicio v0.48.2 — margen lateral global referencia Structured (iPhone ~393).
  static const double homePageMarginH = 18;

  /// Mínimo en zonas muy densas (no sustituye al global salvo casos puntuales).
  static const double homePageMarginDenseH = 16;

  /// Separación vertical entre bloques de Inicio.
  static const double homeSectionGap = 12;

  /// Máxima entre bloques principales (evita > 20 px de aire).
  static const double homeSectionGapMax = 16;

  /// Tras cabecera → primera tarjeta (Greeting).
  static const double homeHeaderToGreetingGap = 14;

  /// Radio tarjetas Home (Structured).
  static const double homeCardRadius = 22;

  /// Radios internos / chapas.
  static const double homeCardRadiusInner = 18;

  static const double homeCardPadding = 14;

  static const double homeCardPaddingCompact = 12;

  /// Barra inferior tipo cápsula.
  static const double homeNavBarHeight = 76;

  static const double homeNavBarRadius = 34;

  static const double homeNavBarHorizontalPadding = 12;

  static const double homeNavIconSize = 26;

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
}
