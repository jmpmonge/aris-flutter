import 'package:flutter/material.dart';

import 'home_scroll_layout.dart';
import '../../../../theme/app_spacing.dart';

/// Conteos visibles de HOY según altura útil (v0.49.73).
class HomeVisibleCounts {
  const HomeVisibleCounts({
    required this.agendaItems,
    required this.taskItems,
    required this.noteItems,
  });

  static const int agendaMin = 2;
  static const int taskMin = 3;
  static const int noteMin = 3;

  final int agendaItems;
  final int taskItems;
  final int noteItems;

  /// Resuelve conteos: HOY crece con el viewport si Aris cabe (v0.48.54).
  static HomeVisibleCounts forListViewport({
    required double listViewportHeight,
    required BuildContext context,
    required int availableEvents,
    required int availableTasks,
    required int availableNotes,
  }) {
    var agenda = agendaMin;
    var tasks = taskMin;
    var notes = noteMin;

    var usedHeight = HomeSummaryLayoutMetrics.estimateCardHeight(
      agendaItems: agenda,
      taskItems: tasks,
      noteItems: notes,
    );

    final budget = listViewportHeight -
        HomeScrollLayout.scrollChromeExcludingSummaryCard(context);

    if (budget <= usedHeight) {
      return HomeVisibleCounts(
        agendaItems: agenda.clamp(0, availableEvents),
        taskItems: tasks.clamp(0, availableTasks),
        noteItems: notes.clamp(0, availableNotes),
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
        2 => notes < availableNotes,
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
          notes++;
      }
      usedHeight += delta;
    }

    return HomeVisibleCounts(
      agendaItems: agenda,
      taskItems: tasks,
      noteItems: notes,
    );
  }
}

/// Alturas de referencia alineadas con [TodaySummaryCard] (v0.49.73).
abstract final class HomeSummaryLayoutMetrics {
  HomeSummaryLayoutMetrics._();

  static const double eventRowHeight = 52;
  static const double eventRowGap = 4;
  static const double taskRowHeight = 35;
  static const double taskRowGap = 3;
  static const double noteLineHeight = 20;
  static const double noteLineGap = 6;

  static const double _sectionHeaderHeight =
      AppSpacing.homeCardHeaderInkPaddingV * 2 + 12;
  static const double _dividerBlockHeight = 14 * 2 + 1;
  static const double _emptyLineHeight = 13.5 * 1.3;

  /// Pequeño extra por fila para no sobrepasar el viewport (v0.48.53).
  static const double _rowEstimateSlack = 2;

  static double incrementalHeightForSection(int section) {
    return switch (section) {
      0 => eventRowHeight + eventRowGap + _rowEstimateSlack,
      1 => taskRowHeight + taskRowGap + _rowEstimateSlack,
      2 => noteLineHeight + noteLineGap + _rowEstimateSlack,
      _ => 0,
    };
  }

  static double estimateCardHeight({
    required int agendaItems,
    required int taskItems,
    required int noteItems,
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

    if (noteItems <= 0) {
      h += _emptyLineHeight;
    } else {
      h += noteItems * noteLineHeight + (noteItems - 1) * noteLineGap;
    }

    return h + 12;
  }
}

/// Ajuste fino si Aris sigue quedando cortada tras el layout (v0.48.53).
extension HomeVisibleCountsTighten on HomeVisibleCounts {
  /// Quita filas de HOY (agenda → tareas → notas) hasta [steps] pasos.
  HomeVisibleCounts tightened(int steps) {
    var agenda = agendaItems;
    var tasks = taskItems;
    var notes = noteItems;

    for (var i = 0; i < steps; i++) {
      if (agenda > HomeVisibleCounts.agendaMin) {
        agenda--;
        continue;
      }
      if (tasks > HomeVisibleCounts.taskMin) {
        tasks--;
        continue;
      }
      if (notes > HomeVisibleCounts.noteMin) {
        notes--;
        continue;
      }
      break;
    }

    return HomeVisibleCounts(
      agendaItems: agenda,
      taskItems: tasks,
      noteItems: notes,
    );
  }
}
