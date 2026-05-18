import 'package:flutter/material.dart';

/// Cabecera compacta de Home — v0.48.1 (bloque superior; no “portada”).
///
/// Tras [SafeArea] del padre aplica **+16 px** aprox. de margen superior.
class ArisHeader extends StatelessWidget {
  const ArisHeader({
    super.key,
    this.onAssistantTap,
  });

  final VoidCallback? onAssistantTap;

  static const Color _titleColor = Color(0xFF132B4F);
  static const Color _subtitleColor = Color(0xFF6E7480);

  /// Rango briefing 22–24 px → 23 px.
  static const double _horizontalMargin = 23;

  /// SafeArea + ~16 px.
  static const double _paddingTop = 16;

  static const double _titleSize = 32;
  static const double _subtitleSize = 13;
  static const double _titleSubtitleGap = 3;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'aris',
          style: TextStyle(
            fontSize: _titleSize,
            fontWeight: FontWeight.w700,
            height: 1.0,
            letterSpacing: -0.45,
            color: _titleColor,
          ),
        ),
        const SizedBox(height: _titleSubtitleGap),
        Text(
          'Tu asistente personal',
          style: TextStyle(
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
        _horizontalMargin,
        _paddingTop,
        _horizontalMargin,
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
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints.tightFor(width: 36, height: 36),
              style: IconButton.styleFrom(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              iconSize: 20,
              icon: Icon(
                Icons.auto_awesome_rounded,
                size: 20,
                color: scheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
