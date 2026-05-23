import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Colores de listas Calendario / Tareas / Notas según tema (v0.49.86 claro).
@immutable
class ArisListPalette extends ThemeExtension<ArisListPalette> {
  const ArisListPalette({
    required this.canvas,
    required this.cardFill,
    required this.cardExpanded,
    required this.borderNormal,
    required this.borderSelected,
    required this.elevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentSky,
    required this.destructive,
    required this.timelineDot,
    required this.eventDotMuted,
    required this.taskSectionLabel,
    required this.noteSectionLabel,
    required this.calendarSectionLabel,
    required this.completedCheck,
    required this.chipFill,
    required this.chipText,
    required this.chipIcon,
  });

  final Color canvas;
  final Color cardFill;
  final Color cardExpanded;
  final Color borderNormal;
  final Color borderSelected;
  final Color elevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color accentSky;
  final Color destructive;
  final Color timelineDot;
  final Color eventDotMuted;
  final Color taskSectionLabel;
  final Color noteSectionLabel;
  final Color calendarSectionLabel;
  final Color completedCheck;
  final Color chipFill;
  final Color chipText;
  final Color chipIcon;

  static ArisListPalette of(BuildContext context) =>
      Theme.of(context).extension<ArisListPalette>()!;

  static const dark = ArisListPalette(
    canvas: AppColors.noteWideCanvas,
    cardFill: AppColors.noteWideSurface,
    cardExpanded: Color(0xFF131E2A),
    borderNormal: Color(0x40243244),
    borderSelected: Color(0x665EA8FF),
    elevated: Color(0xFF151F2B),
    textPrimary: AppColors.noteWideTextPrimary,
    textSecondary: AppColors.noteWideTextSecondary,
    textMuted: AppColors.noteWideTextMuted,
    accent: AppColors.noteArisBlue,
    accentSky: AppColors.noteArisSky,
    destructive: AppColors.noteDestructive,
    timelineDot: AppColors.noteArisBlue,
    eventDotMuted: Color(0xFF6F7B8A),
    taskSectionLabel: AppColors.noteArisBlue,
    noteSectionLabel: AppColors.noteArisBlue,
    calendarSectionLabel: AppColors.noteArisBlue,
    completedCheck: AppColors.noteArisBlue,
    chipFill: Color(0x33151F2B),
    chipText: AppColors.noteArisSky,
    chipIcon: AppColors.noteArisBlue,
  );

  static const light = ArisListPalette(
    canvas: Color(0xFFF5F7FB),
    cardFill: Color(0xFFFFFFFF),
    cardExpanded: Color(0xFFFFFFFF),
    borderNormal: Color(0xFFDCE5F0),
    borderSelected: Color(0xFF8BB8FF),
    elevated: Color(0xFFF8FAFD),
    textPrimary: Color(0xFF1B2A40),
    textSecondary: Color(0xFF6C7A8B),
    textMuted: Color(0xFF8A97A8),
    accent: Color(0xFF79AFFF),
    accentSky: Color(0xFF5E97F6),
    destructive: AppColors.noteDestructive,
    timelineDot: Color(0xFF6EA8FF),
    eventDotMuted: Color(0xFFA2AEBC),
    taskSectionLabel: Color(0xFF6C9EF5),
    noteSectionLabel: Color(0xFF7CCB9A),
    calendarSectionLabel: Color(0xFF79AFFF),
    completedCheck: Color(0xFF79AFFF),
    chipFill: Color(0xFFEAF2FF),
    chipText: Color(0xFF2D5FA8),
    chipIcon: Color(0xFF79AFFF),
  );

  @override
  ArisListPalette copyWith({
    Color? canvas,
    Color? cardFill,
    Color? cardExpanded,
    Color? borderNormal,
    Color? borderSelected,
    Color? elevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? accentSky,
    Color? destructive,
    Color? timelineDot,
    Color? eventDotMuted,
    Color? taskSectionLabel,
    Color? noteSectionLabel,
    Color? calendarSectionLabel,
    Color? completedCheck,
    Color? chipFill,
    Color? chipText,
    Color? chipIcon,
  }) {
    return ArisListPalette(
      canvas: canvas ?? this.canvas,
      cardFill: cardFill ?? this.cardFill,
      cardExpanded: cardExpanded ?? this.cardExpanded,
      borderNormal: borderNormal ?? this.borderNormal,
      borderSelected: borderSelected ?? this.borderSelected,
      elevated: elevated ?? this.elevated,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      accentSky: accentSky ?? this.accentSky,
      destructive: destructive ?? this.destructive,
      timelineDot: timelineDot ?? this.timelineDot,
      eventDotMuted: eventDotMuted ?? this.eventDotMuted,
      taskSectionLabel: taskSectionLabel ?? this.taskSectionLabel,
      noteSectionLabel: noteSectionLabel ?? this.noteSectionLabel,
      calendarSectionLabel: calendarSectionLabel ?? this.calendarSectionLabel,
      completedCheck: completedCheck ?? this.completedCheck,
      chipFill: chipFill ?? this.chipFill,
      chipText: chipText ?? this.chipText,
      chipIcon: chipIcon ?? this.chipIcon,
    );
  }

  @override
  ArisListPalette lerp(ThemeExtension<ArisListPalette>? other, double t) {
    if (other is! ArisListPalette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return ArisListPalette(
      canvas: l(canvas, other.canvas),
      cardFill: l(cardFill, other.cardFill),
      cardExpanded: l(cardExpanded, other.cardExpanded),
      borderNormal: l(borderNormal, other.borderNormal),
      borderSelected: l(borderSelected, other.borderSelected),
      elevated: l(elevated, other.elevated),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textMuted: l(textMuted, other.textMuted),
      accent: l(accent, other.accent),
      accentSky: l(accentSky, other.accentSky),
      destructive: l(destructive, other.destructive),
      timelineDot: l(timelineDot, other.timelineDot),
      eventDotMuted: l(eventDotMuted, other.eventDotMuted),
      taskSectionLabel: l(taskSectionLabel, other.taskSectionLabel),
      noteSectionLabel: l(noteSectionLabel, other.noteSectionLabel),
      calendarSectionLabel: l(calendarSectionLabel, other.calendarSectionLabel),
      completedCheck: l(completedCheck, other.completedCheck),
      chipFill: l(chipFill, other.chipFill),
      chipText: l(chipText, other.chipText),
      chipIcon: l(chipIcon, other.chipIcon),
    );
  }
}

extension ArisListContext on BuildContext {
  ArisListPalette get arisList => ArisListPalette.of(this);
}
