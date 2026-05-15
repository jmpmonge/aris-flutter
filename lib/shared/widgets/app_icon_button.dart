import 'package:flutter/material.dart';

/// Botón de icono con área táctil consistente (HIG / Material).
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.selected = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = color ?? (selected ? scheme.primary : scheme.onSurfaceVariant);

    final button = IconButton(
      icon: Icon(icon),
      color: fg,
      isSelected: selected,
      onPressed: onPressed,
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
