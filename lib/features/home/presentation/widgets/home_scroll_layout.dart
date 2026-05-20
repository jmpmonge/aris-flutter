import 'package:flutter/material.dart';

import '../../../../shared/widgets/home_aris_reply_card.dart';
import '../../../../theme/app_spacing.dart';
import 'home_visible_counts.dart';

/// Métricas de layout scroll + dock Aris en Home (v0.48.51).
abstract final class HomeScrollLayout {
  HomeScrollLayout._();

  /// Padding inferior del scroll (aire mínimo tarjeta → input).
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

  /// Alto fijo estimado: saludo + HOY + gap + tarjeta Aris (sin espaciador).
  static double estimateStackedContentHeight({
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

  /// Espaciador flexible (estimado por conteos HOY).
  static double flexSpacerHeight({
    required double viewportHeight,
    required HomeVisibleCounts counts,
    required BuildContext context,
  }) {
    final usable = viewportHeight - scrollContentBottomPadding(context);
    final stacked = estimateStackedContentHeight(
      counts: counts,
      context: context,
    );
    return (usable - stacked).clamp(0.0, double.infinity);
  }

  /// Espaciador con altura real medida de [TodaySummaryCard] (v0.48.51).
  static double flexSpacerFromMeasuredHoy({
    required double viewportHeight,
    required double measuredHoyHeight,
    required BuildContext context,
  }) {
    final usable = viewportHeight - scrollContentBottomPadding(context);
    final stacked = AppSpacing.homeFixedDateToEphemeralGap +
        HomeSummaryLayoutMetrics.greetingBlockHeight +
        AppSpacing.homeGreetingToHoyGap +
        measuredHoyHeight +
        sectionGapBeforeAris(context) +
        HomeArisReplyCard.bodyHeight;
    return (usable - stacked).clamp(0.0, double.infinity);
  }
}
