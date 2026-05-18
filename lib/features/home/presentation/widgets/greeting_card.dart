import 'package:flutter/material.dart';

import '../../../../theme/app_spacing.dart';

/// Tarjeta de saludo — v0.48.2 Structured; foto derecha fundida (sin efecto banner).
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

  static const String _coffeeAsset = 'assets/images/greeting_coffee_morning.png';

  static const double _cardHeight = 96;
  static const double _radius = AppSpacing.homeCardRadius;
  static const double _padH = 14;
  static const double _padV = 12;
  static const double _iconDiameter = 34;
  static const double _iconGlyph = 20;

  /// Rango visible Structured: 96–108.
  static const double _coffeeWidth = 100;

  /// Color de arranque del panel (alineado con velo sobre la foto).
  static const Color _cardCream = Color(0xFFFFFEFE);

  @override
  Widget build(BuildContext context) {
    final lines = secondaryLines.map((s) => s.trim()).where((s) => s.isNotEmpty).take(2).toList();

    final theme = Theme.of(context);
    final greetingStyle = theme.textTheme.titleLarge?.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          height: 1.15,
          color: _primaryText,
        ) ??
        const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          height: 1.15,
          color: _primaryText,
        );

    final secondaryChildren = <Widget>[];
    for (var i = 0; i < lines.length; i++) {
      secondaryChildren.add(
        Text(
          lines[i],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            height: 1.22,
            fontWeight: FontWeight.w400,
            color: _secondaryText,
          ),
        ),
      );
      if (i < lines.length - 1) {
        secondaryChildren.add(const SizedBox(height: 1));
      }
    }

    final sunDisk = Container(
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
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.homePageMarginH),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          boxShadow: [
            BoxShadow(
              color: _primaryText.withValues(alpha: 0.02),
              blurRadius: AppSpacing.shadowBlurHomeCard,
              offset: AppSpacing.shadowOffsetHomeCard,
            ),
          ],
        ),
        child: SizedBox(
          height: _cardHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_radius),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _cardCream,
                          const Color(0xFFFFFCF7),
                          const Color(0xFFFFF6EC).withValues(alpha: 0.95),
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: _coffeeWidth,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(_radius),
                    bottomRight: Radius.circular(_radius),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        _coffeeAsset,
                        fit: BoxFit.cover,
                        alignment: Alignment.centerLeft,
                        filterQuality: FilterQuality.medium,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              _cardCream.withValues(alpha: 0.98),
                              _cardCream.withValues(alpha: 0.9),
                              _cardCream.withValues(alpha: 0.62),
                              _cardCream.withValues(alpha: 0.28),
                              _cardCream.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.1, 0.28, 0.52, 0.9],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    _padH,
                    _padV,
                    _coffeeWidth + 6,
                    _padV,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final textSlotW = (constraints.maxWidth - _iconDiameter - 12).clamp(0.0, double.infinity);
                      final tp = TextPainter(
                        text: TextSpan(text: greeting, style: greetingStyle),
                        textDirection: TextDirection.ltr,
                        maxLines: 1,
                      )..layout(maxWidth: textSlotW);
                      final baselineDist = tp.computeDistanceToActualBaseline(TextBaseline.alphabetic);
                      final topPad = (baselineDist - _iconDiameter / 2).clamp(0.0, double.infinity);

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: topPad),
                            child: sunDisk,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  greeting,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: greetingStyle,
                                ),
                                if (secondaryChildren.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  ...secondaryChildren,
                                ],
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
