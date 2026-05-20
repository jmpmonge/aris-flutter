import 'package:flutter/material.dart';

import '../../../../shared/widgets/home_aris_reply_card.dart';
import '../../../../theme/app_spacing.dart';
import 'home_visible_counts.dart';

/// Métricas de layout scroll + dock Aris en Home (v0.48.50).
abstract final class HomeScrollLayout {
  HomeScrollLayout._();

  /// Altura aproximada del bloque bottom nav del shell (referencia documental).
  static const double shellBottomNavBlockHeight =
      4 + 8 + AppSpacing.homeNavBarHeight + 4;

  /// Zona inferior reservada: dock input + aire visual + safe area.
  static double reservedBottomZone(BuildContext context) {
    return HomeArisFixedInputBar.dockHeight +
        scrollContentBottomPadding(context) +
        MediaQuery.paddingOf(context).bottom;
  }

  /// Padding inferior dentro del scroll (aire tarjeta → línea del input).
  static double scrollContentBottomPadding(BuildContext context) {
    if (MediaQuery.sizeOf(context).height < 680) {
      return AppSpacing.xs;
    }
    return AppSpacing.homeArisCardToInputGap;
  }

  /// Alto mínimo del bloque scrollable (viewport − padding de cola).
  static double scrollMinHeight({
    required double viewportHeight,
    required BuildContext context,
  }) {
    return (viewportHeight - scrollContentBottomPadding(context))
        .clamp(0.0, double.infinity);
  }

  /// Gap HOY → Aris; compacta en pantallas bajas.
  static double sectionGapBeforeAris(BuildContext context) {
    if (MediaQuery.sizeOf(context).height < 680) {
      return AppSpacing.homeSectionGap;
    }
    return AppSpacing.homeSectionGapMax;
  }

  /// Estima alto del contenido sin el espaciador flexible.
  static double estimateListContentHeight({
    required HomeVisibleCounts counts,
    required BuildContext context,
  }) {
    return AppSpacing.homeFixedDateToEphemeralGap +
        HomeSummaryLayoutMetrics.greetingBlockHeight +
        AppSpacing.homeGreetingToHoyGap +
        HomeSummaryLayoutMetrics.estimateCardHeight(
          agendaItems: counts.agendaItems,
          taskItems: counts.taskItems,
          mailItems: counts.mailItems,
        ) +
        sectionGapBeforeAris(context) +
        HomeArisReplyCard.bodyHeight;
  }
}
