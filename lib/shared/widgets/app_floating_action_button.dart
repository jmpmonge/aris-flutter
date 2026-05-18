import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// FAB circular — v0.48.2 medidas Structured (64 / icono 34).
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
    return FloatingActionButton(
      heroTag: heroTag ?? 'aris_fab_default',
      tooltip: tooltip,
      onPressed: onPressed,
      shape: const CircleBorder(),
      child: Icon(icon, size: AppSpacing.homeFabIconSize),
    );
  }
}
