import 'package:flutter/material.dart';

/// Primera tarjeta de saludo — v0.48.1 compacta (~90–94 px alto), sin aspecto banner.
class GreetingCard extends StatelessWidget {
  const GreetingCard({
    super.key,
    required this.greeting,
    required this.secondaryLines,
  });

  final String greeting;

  /// Máximo dos líneas breves (presentación; no toca servicios).
  final List<String> secondaryLines;

  static const Color _primaryText = Color(0xFF132B4F);
  static const Color _secondaryText = Color(0xFF5F6673);

  static const double _horizontalMargin = 23;
  static const double _cardHeight = 92;
  static const double _radius = 21;
  static const double _padH = 15;
  static const double _padV = 13;
  static const double _iconDiameter = 35;
  static const double _iconGlyph = 19;

  static const double _primaryFontSize = 17;
  static const double _secondaryFontSize = 13.25;

  /// Zona decorativa derecha (briefing ~82–96 px).
  static const double _decorWidth = 88;

  @override
  Widget build(BuildContext context) {
    final lines = secondaryLines.map((s) => s.trim()).where((s) => s.isNotEmpty).take(2).toList();

    final secondaryChildren = <Widget>[];
    for (var i = 0; i < lines.length; i++) {
      secondaryChildren.add(
        Text(
          lines[i],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: _secondaryFontSize,
            height: 1.2,
            fontWeight: FontWeight.w400,
            color: _secondaryText,
          ),
        ),
      );
      if (i < lines.length - 1) {
        secondaryChildren.add(const SizedBox(height: 1));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalMargin),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          boxShadow: [
            BoxShadow(
              color: _primaryText.withValues(alpha: 0.028),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_radius),
          child: SizedBox(
            height: _cardHeight,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFFFEFE),
                          const Color(0xFFFFFCF7),
                          const Color(0xFFFFF6EC).withValues(alpha: 0.95),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: _decorWidth,
                  child: IgnorePointer(
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      alignment: Alignment.centerRight,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.transparent,
                                const Color(0xFFFFD6A8).withValues(alpha: 0.14),
                                const Color(0xFFFFBE7A).withValues(alpha: 0.24),
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ),
                          ),
                          child: const SizedBox.expand(),
                        ),
                        Positioned(
                          right: -18,
                          bottom: -22,
                          child: Opacity(
                            opacity: 0.22,
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFFFFA857).withValues(alpha: 0.55),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _padH,
                      vertical: _padV,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: _iconDiameter,
                          height: _iconDiameter,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFFFFF4E6),
                                const Color(0xFFFFE8CC).withValues(alpha: 0.88),
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.wb_sunny_rounded,
                            size: _iconGlyph,
                            color: Color(0xFFD08300),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 66),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  greeting,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: _primaryFontSize,
                                    fontWeight: FontWeight.w700,
                                    height: 1.15,
                                    color: _primaryText,
                                  ),
                                ),
                                if (secondaryChildren.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  ...secondaryChildren,
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
