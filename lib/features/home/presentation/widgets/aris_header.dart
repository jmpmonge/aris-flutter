import 'package:flutter/material.dart';

import '../../../../theme/app_spacing.dart';

/// Cabecera Home — v0.48.2 Structured (presencia, sin “portada”).
class ArisHeader extends StatelessWidget {
  const ArisHeader({
    super.key,
    this.onAssistantTap,
  });

  final VoidCallback? onAssistantTap;

  static const Color _titleColor = Color(0xFF132B4F);
  static const Color _subtitleColor = Color(0xFF6E7480);

  /// SafeArea ya aplica en [HomeScreen]; aquí +18 px de ritmo superior.
  static const double _paddingTop = 18;

  static const double _titleSize = 32;
  static const double _subtitleSize = 14;
  static const double _titleSubtitleGap = 3;

  static const double _assistantButtonSize = 44;
  static const double _assistantIconSize = 23;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'aris',
          style: const TextStyle(
            fontSize: _titleSize,
            fontWeight: FontWeight.w700,
            height: 1.0,
            letterSpacing: -0.4,
            color: _titleColor,
          ),
        ),
        const SizedBox(height: _titleSubtitleGap),
        Text(
          'Tu asistente personal',
          style: const TextStyle(
            fontSize: _subtitleSize,
            height: 1.25,
            fontWeight: FontWeight.w400,
            color: _subtitleColor,
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.homePageMarginH,
        _paddingTop,
        AppSpacing.homePageMarginH,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: column),
          if (onAssistantTap != null) ...[
            const SizedBox(width: 4),
            IconButton.filledTonal(
              onPressed: onAssistantTap,
              tooltip: 'Hablar con Aris',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(
                width: _assistantButtonSize,
                height: _assistantButtonSize,
              ),
              style: IconButton.styleFrom(
                visualDensity: VisualDensity.standard,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              iconSize: _assistantIconSize,
              icon: Icon(
                Icons.auto_awesome_rounded,
                size: _assistantIconSize,
                color: scheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
