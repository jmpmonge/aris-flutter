import 'package:flutter/material.dart';

import '../../../../shared/widgets/home_aris_reply_card.dart';
import '../../../../theme/app_spacing.dart';

/// Reserva de altura en el viewport para que Aris siga visible (v0.48.52).
abstract final class HomeScrollLayout {
  HomeScrollLayout._();

  /// Margen de seguridad sobre la altura estimada de la tarjeta Aris.
  static const double arisCardSafetyMargin = 8;

  /// Padding inferior del scroll (aire mínimo).
  static double scrollContentBottomPadding(BuildContext context) {
    if (MediaQuery.sizeOf(context).height < 680) {
      return AppSpacing.xxs;
    }
    return AppSpacing.sm;
  }

  /// Gap entre HOY y tarjeta Aris.
  static double sectionGapBeforeAris(BuildContext context) {
    if (MediaQuery.sizeOf(context).height < 680) {
      return AppSpacing.homeSectionGap;
    }
    return AppSpacing.homeSectionGapMax;
  }

  /// Chrome fijo que debe caber junto a HOY para que Aris no quede oculta.
  static double scrollChromeExcludingSummaryCard(BuildContext context) {
    return AppSpacing.homeFixedDateToEphemeralGap +
        AppSpacing.homeGreetingToHoyGap +
        52 + // greetingBlockHeight — evita import circular con metrics
        HomeArisReplyCard.bodyHeight +
        arisCardSafetyMargin +
        sectionGapBeforeAris(context) +
        scrollContentBottomPadding(context);
  }
}
