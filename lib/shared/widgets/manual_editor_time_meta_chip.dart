import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Geometría unificada del chip de hora en editores manuales (v0.49.23).
abstract final class ManualEditorTimeMetaChipStyle {
  static const double iconSize = 15;
  static const double borderRadius = 14;
  static const EdgeInsets padding =
      EdgeInsets.symmetric(horizontal: 7, vertical: 4);
  static const double iconLabelGap = 4;
  static const double fillAlpha = 0.14;
}

/// Chip compacto de hora; el acento lo define cada sección.
class ManualEditorTimeMetaChip extends StatelessWidget {
  const ManualEditorTimeMetaChip({
    super.key,
    required this.accent,
    required this.active,
    required this.onTap,
    this.valueLabel,
    this.enabled = true,
  });

  final Color accent;
  final bool active;
  final VoidCallback? onTap;
  final String? valueLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = active
        ? accent
        : scheme.onSurfaceVariant.withValues(alpha: 0.38);

    return Material(
      color: active
          ? accent.withValues(alpha: ManualEditorTimeMetaChipStyle.fillAlpha)
          : scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius:
          BorderRadius.circular(ManualEditorTimeMetaChipStyle.borderRadius),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius:
            BorderRadius.circular(ManualEditorTimeMetaChipStyle.borderRadius),
        child: Padding(
          padding: ManualEditorTimeMetaChipStyle.padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_rounded,
                size: ManualEditorTimeMetaChipStyle.iconSize,
                color: color,
              ),
              if (valueLabel != null && valueLabel!.isNotEmpty) ...[
                const SizedBox(width: ManualEditorTimeMetaChipStyle.iconLabelGap),
                Text(
                  valueLabel!,
                  style: tt.labelSmall?.copyWith(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.05,
                    height: 1.1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
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
