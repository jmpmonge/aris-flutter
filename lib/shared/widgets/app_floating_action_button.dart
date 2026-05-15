import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// FAB con tamaño táctil mínimo y forma acorde al tema (acento Clara).
class AppFloatingActionButton extends StatelessWidget {
  const AppFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.heroTag,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.minTouchTarget + 8,
      height: AppSpacing.minTouchTarget + 8,
      child: FloatingActionButton(
        heroTag: heroTag ?? 'aris_fab_default',
        tooltip: tooltip,
        onPressed: onPressed,
        child: Icon(icon, size: 26),
      ),
    );
  }
}
