import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Geometría de campos meta compactos en editores manuales (v0.49.69).
abstract final class EditorCompactMetaFieldStyle {
  static const double height = AppSpacing.editorMetaFieldHeight;
  static const double borderRadius = AppSpacing.radiusMd;
  static const EdgeInsets padding = EdgeInsets.symmetric(
    horizontal: AppSpacing.editorMetaFieldPaddingH,
  );
  static const double iconSize = AppSpacing.editorMetaFieldIconSize;
  static const double iconLabelGap = AppSpacing.editorMetaFieldGap;
  static const double activeFillAlpha = 0.14;
  static const double borderAlpha = 0.55;
  static const double iconOnlyMinWidth = 36;
}

/// Campo meta compacto rectangular para filas fecha/hora/bandera|alarma.
class EditorCompactMetaField extends StatelessWidget {
  const EditorCompactMetaField({
    super.key,
    required this.icon,
    required this.accent,
    required this.active,
    required this.onTap,
    required this.surfaceColor,
    required this.borderColor,
    this.valueLabel,
    this.iconOnly = false,
    this.enabled = true,
    this.mutedForeground,
  });

  final IconData icon;
  final Color accent;
  final bool active;
  final VoidCallback? onTap;
  final Color surfaceColor;
  final Color borderColor;
  final String? valueLabel;
  final bool iconOnly;
  final bool enabled;
  final Color? mutedForeground;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final inactiveColor =
        mutedForeground ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final color = active
        ? accent
        : inactiveColor.withValues(alpha: 0.55);
    final showLabel =
        !iconOnly && valueLabel != null && valueLabel!.isNotEmpty;
    final fieldPadding = iconOnly
        ? EdgeInsets.zero
        : EditorCompactMetaFieldStyle.padding;

    return Material(
      color: active
          ? accent.withValues(alpha: EditorCompactMetaFieldStyle.activeFillAlpha)
          : surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(EditorCompactMetaFieldStyle.borderRadius),
        side: BorderSide(
          color: borderColor.withValues(
            alpha: EditorCompactMetaFieldStyle.borderAlpha,
          ),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: SizedBox(
          height: EditorCompactMetaFieldStyle.height,
          width: iconOnly ? EditorCompactMetaFieldStyle.iconOnlyMinWidth : null,
          child: Padding(
            padding: fieldPadding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:
                  iconOnly ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(icon, size: EditorCompactMetaFieldStyle.iconSize, color: color),
                if (showLabel) ...[
                  const SizedBox(width: EditorCompactMetaFieldStyle.iconLabelGap),
                  Text(
                    valueLabel!,
                    style: tt.labelSmall?.copyWith(
                      color: color,
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
      ),
    );
  }
}
