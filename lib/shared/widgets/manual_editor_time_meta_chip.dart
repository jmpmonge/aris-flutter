import 'package:flutter/material.dart';

import 'editor_compact_meta_field.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Geometría unificada del campo de hora en editores manuales (v0.49.23).
abstract final class ManualEditorTimeMetaChipStyle {
  static const double iconSize = EditorCompactMetaFieldStyle.iconSize;
  static const double borderRadius = EditorCompactMetaFieldStyle.borderRadius;
  static const EdgeInsets padding = EditorCompactMetaFieldStyle.padding;
  static const double iconLabelGap = EditorCompactMetaFieldStyle.iconLabelGap;
  static const double fillAlpha = EditorCompactMetaFieldStyle.activeFillAlpha;
}

/// Campo compacto de hora; el acento lo define cada sección.
class ManualEditorTimeMetaChip extends StatelessWidget {
  const ManualEditorTimeMetaChip({
    super.key,
    required this.accent,
    required this.active,
    required this.onTap,
    this.valueLabel,
    this.enabled = true,
    this.surfaceColor,
    this.borderColor,
    this.mutedForeground,
  });

  final Color accent;
  final bool active;
  final VoidCallback? onTap;
  final String? valueLabel;
  final bool enabled;
  final Color? surfaceColor;
  final Color? borderColor;
  final Color? mutedForeground;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return EditorCompactMetaField(
      icon: Icons.access_time_rounded,
      accent: accent,
      active: active,
      onTap: onTap,
      valueLabel: valueLabel,
      enabled: enabled,
      surfaceColor:
          surfaceColor ?? scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderColor: borderColor ?? scheme.outlineVariant,
      mutedForeground: mutedForeground,
    );
  }
}

/// CTA principal del sistema en editores manuales (azul marino / azul oscuro).
abstract final class ManualEditorPrimaryCtaStyle {
  static ButtonStyle style(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.calendarBlueDark : AppColors.primaryDeep;
    return FilledButton.styleFrom(
      elevation: 0,
      backgroundColor: bg,
      foregroundColor: AppColors.onPrimaryContrast,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    );
  }
}
