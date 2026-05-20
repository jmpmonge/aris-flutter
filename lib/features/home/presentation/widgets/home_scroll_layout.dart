import 'package:flutter/material.dart';

import '../../../../shared/widgets/home_aris_reply_card.dart';
import '../../../../theme/app_spacing.dart';

/// Reserva de altura en el viewport para que Aris siga visible (v0.48.53).
abstract final class HomeScrollLayout {
  HomeScrollLayout._();

  static const double greetingBlockHeight = 56;

  /// Margen extra: tarjeta Aris real suele ser algo más alta que bodyHeight.
  static const double arisCardLayoutReserve =
      HomeArisReplyCard.bodyHeight + 20;

  /// Slack: HOY renderizado suele superar la estimación analítica.
  static const double hoyRenderSlack = 24;

  static double scrollContentBottomPadding(BuildContext context) {
    return AppSpacing.xxs;
  }

  static double sectionGapBeforeAris(BuildContext context) {
    if (MediaQuery.sizeOf(context).height < 720) {
      return AppSpacing.homeSectionGap;
    }
    return 14;
  }

  /// Altura no-HOY que debe reservarse en el viewport.
  static double scrollChromeExcludingSummaryCard(BuildContext context) {
    return AppSpacing.homeFixedDateToEphemeralGap +
        AppSpacing.homeGreetingToHoyGap +
        greetingBlockHeight +
        arisCardLayoutReserve +
        sectionGapBeforeAris(context) +
        scrollContentBottomPadding(context) +
        hoyRenderSlack;
  }
}
