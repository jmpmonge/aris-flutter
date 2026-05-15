import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Campo de búsqueda redondeado alineado con [InputDecorationTheme].
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText = 'Buscar',
    this.readOnly = false,
    this.onTap,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String hintText;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        readOnly: readOnly,
        onTap: onTap,
        autofocus: autofocus,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hintText,
          isDense: true,
          prefixIcon: Icon(Icons.search_rounded, color: scheme.onSurfaceVariant),
          prefixIconConstraints: const BoxConstraints(
            minWidth: AppSpacing.minTouchTarget,
            minHeight: AppSpacing.minTouchTarget,
          ),
        ),
      ),
    );
  }
}
