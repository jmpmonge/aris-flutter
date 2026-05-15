import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Título de bloque dentro de formularios locales (Aris).
class FormSectionTitle extends StatelessWidget {
  const FormSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        text,
        style: textTheme.labelLarge?.copyWith(
          letterSpacing: 0.6,
          color: scheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
