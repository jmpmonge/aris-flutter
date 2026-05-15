import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'breakpoints.dart';

/// Contenedor global: **ancho completo** en móvil nativo; en **web ancha**, columna
/// centrada tipo iPhone con fondo exterior acorde al tema.
class ResponsiveAppFrame extends StatelessWidget {
  const ResponsiveAppFrame({super.key, required this.child});

  final Widget child;

  static Color shellBackground(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final base = scheme.surfaceContainerLowest;
    final tint = scheme.primary;
    return Color.alphaBlend(
      tint.withValues(alpha: brightness == Brightness.light ? 0.05 : 0.1),
      base,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        final scheme = Theme.of(context).colorScheme;
        final shell = shellBackground(context);

        final screenSize = MediaQuery.sizeOf(context);
        final boundedH = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : screenSize.height;
        final availableW = constraints.maxWidth;

        final marginH = LayoutBreakpoints.webFrameOuterPaddingH * 2;
        final useFrame =
            availableW >
            LayoutBreakpoints.webMobileFrameMaxWidth + marginH;

        if (!useFrame) {
          return ColoredBox(color: shell, child: child);
        }

        final rawInner =
            boundedH - LayoutBreakpoints.webFrameOuterPaddingV * 2;
        if (rawInner <= 0) {
          return ColoredBox(color: shell, child: child);
        }
        final innerH = rawInner;

        return ColoredBox(
          color: shell,
          child: Align(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: LayoutBreakpoints.webFrameOuterPaddingH,
                vertical: LayoutBreakpoints.webFrameOuterPaddingV,
              ),
              child: SizedBox(
                width: LayoutBreakpoints.webMobileFrameMaxWidth,
                height: innerH,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      LayoutBreakpoints.webFrameBorderRadius,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.shadow.withValues(alpha: 0.22),
                        blurRadius: 36,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      LayoutBreakpoints.webFrameBorderRadius,
                    ),
                    child: ColoredBox(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          size: Size(
                            LayoutBreakpoints.webMobileFrameMaxWidth,
                            innerH,
                          ),
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
