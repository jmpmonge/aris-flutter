import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Botón primario o secundario para formularios locales.
class AppFormButton extends StatelessWidget {
  const AppFormButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = true,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final child = primary
        ? FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: Text(label),
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: Text(label),
          );

    if (!expanded) return child;
    return SizedBox(width: double.infinity, child: child);
  }
}
