import '../../../../shared/widgets/home_aris_reply_card.dart';
import '../../../../theme/app_spacing.dart';

/// Conteos visibles de HOY según altura útil (v0.48.47).
class HomeVisibleCounts {
  const HomeVisibleCounts({
    required this.agendaItems,
    required this.taskItems,
    required this.mailItems,
  });

  static const int agendaMin = 2;
  static const int taskMin = 3;
  static const int mailMin = 1;

  final int agendaItems;
  final int taskItems;
  final int mailItems;

  /// Resuelve conteos a partir del alto del área scrollable de Inicio.
  static HomeVisibleCounts forListViewport({
    required double listViewportHeight,
    required int availableEvents,
    required int availableTasks,
    required int availableMails,
  }) {
    var agenda = agendaMin;
    var tasks = taskMin;
    var mail = mailMin;

    var usedHeight = HomeSummaryLayoutMetrics.estimateCardHeight(
      agendaItems: agenda,
      taskItems: tasks,
      mailItems: mail,
    );

    final budget = listViewportHeight -
        HomeSummaryLayoutMetrics.scrollChromeExcludingSummaryCard;

    if (budget <= usedHeight) {
      return HomeVisibleCounts(
        agendaItems: agenda.clamp(0, availableEvents),
        taskItems: tasks.clamp(0, availableTasks),
        mailItems: mail.clamp(0, availableMails),
      );
    }

    var slotRound = 0;
    var guard = 0;
    while (guard < 48) {
      guard++;
      final section = slotRound % 3;
      final canAdd = switch (section) {
        0 => agenda < availableEvents,
        1 => tasks < availableTasks,
        2 => mail < availableMails,
        _ => false,
      };
      slotRound++;

      if (!canAdd) continue;

      final delta = HomeSummaryLayoutMetrics.incrementalHeightForSection(
        section,
      );
      if (usedHeight + delta > budget) break;

      switch (section) {
        case 0:
          agenda++;
        case 1:
          tasks++;
        case 2:
          mail++;
      }
      usedHeight += delta;
    }

    return HomeVisibleCounts(
      agendaItems: agenda,
      taskItems: tasks,
      mailItems: mail,
    );
  }
}

/// Alturas de referencia alineadas con [TodaySummaryCard] (v0.48.47).
abstract final class HomeSummaryLayoutMetrics {
  HomeSummaryLayoutMetrics._();

  static const double eventRowHeight = 52;
  static const double eventRowGap = 4;
  static const double taskRowHeight = 35;
  static const double taskRowGap = 3;
  static const double mailFirstBlockHeight = 47;
  static const double mailExtraBlockHeight = 44;

  static const double _sectionHeaderHeight =
      AppSpacing.homeCardHeaderInkPaddingV * 2 + 12;
  static const double _dividerBlockHeight = 14 * 2 + 1;
  static const double _emptyLineHeight = 13.5 * 1.3;
  static const double _greetingBlockHeight = 52;

  static const double _arisCompactHeight = HomeArisReplyCard.bodyHeight;

  /// Chrome fijo dentro del ListView excepto la tarjeta HOY.
  static const double scrollChromeExcludingSummaryCard =
      AppSpacing.homeFixedDateToEphemeralGap +
      _greetingBlockHeight +
      AppSpacing.homeGreetingToHoyGap +
      _arisCompactHeight +
      AppSpacing.homeSectionGapMax;

  static double incrementalHeightForSection(int section) {
    return switch (section) {
      0 => eventRowHeight + eventRowGap,
      1 => taskRowHeight + taskRowGap,
      2 => mailExtraBlockHeight,
      _ => 0,
    };
  }

  static double estimateCardHeight({
    required int agendaItems,
    required int taskItems,
    required int mailItems,
  }) {
    var h = AppSpacing.homeCardPadding * 2;
    h += _sectionHeaderHeight * 3;
    h += AppSpacing.homeCardHeaderToContentGap * 2;
    h += AppSpacing.homeTasksSectionHeaderToFirstTaskGap;
    h += _dividerBlockHeight * 2;

    if (agendaItems > 0) {
      h += agendaItems * eventRowHeight +
          (agendaItems - 1) * eventRowGap;
    } else {
      h += _emptyLineHeight;
    }

    if (taskItems > 0) {
      h += taskItems * taskRowHeight + (taskItems - 1) * taskRowGap;
    } else {
      h += _emptyLineHeight;
    }

    if (mailItems <= 0) {
      h += _emptyLineHeight;
    } else if (mailItems == 1) {
      h += mailFirstBlockHeight;
    } else {
      h += mailFirstBlockHeight +
          (mailItems - 1) * mailExtraBlockHeight;
    }

    return h;
  }
}
