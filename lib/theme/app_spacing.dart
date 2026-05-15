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

  /// Separación inferior en listas cuando hay FAB flotante centrado.
  static const double fabStackClearance = 100;

  /// Espacio vertical **uniforme** entre bloques de Inicio (cabecera, tarjetas, reciente)
  /// y respiro final antes de la barra de chat. Valor intermedio (16–24) para ritmo premium.
  static const double homeSectionSpacing = 20;

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
  static const double cardElevationLight = 2;
  static const double cardElevationDark = 1;

  /// Área mínima recomendada para targets (Human Interface Guidelines).
  static const double minTouchTarget = 44;
}
