import 'package:flutter/material.dart';

import '../../../../shared/widgets/home_weather_icon.dart';

/// Bloque de clima para Home (v0.49.51).
///
/// [weatherBlockScale] escala el bloque completo (icono, grados, ciudad, gaps).
class HomeWeatherBlock extends StatelessWidget {
  const HomeWeatherBlock({
    super.key,
    required this.temperature,
    required this.city,
    required this.sunColor,
    required this.scheme,
    required this.isDark,
    this.weatherBlockScale = 1,
    this.shiftLeft = 5.0,
  });

  static const double weatherBlockCompactScale = 0.78;

  static const double baseIconSize = 38;
  static const double baseTemperatureFontSize = 17.5;
  static const double baseCityFontSize = 11;
  static const double baseIconTextGap = 8;
  static const double baseTempCityGap = 3;

  final String temperature;
  final String city;
  final Color sunColor;
  final ColorScheme scheme;
  final bool isDark;
  final double weatherBlockScale;
  final double shiftLeft;

  @override
  Widget build(BuildContext context) {
    final double blockScale = weatherBlockScale.clamp(0.01, 1.5);

    final tempStyle = TextStyle(
      fontSize: baseTemperatureFontSize,
      height: 1.05,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    );
    final cityStyle = TextStyle(
      fontSize: baseCityFontSize,
      height: 1.05,
      fontWeight: FontWeight.w400,
      color: scheme.onSurfaceVariant.withValues(alpha: isDark ? 0.70 : 0.65),
    );

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        HomeWeatherIcon(size: baseIconSize, sunColor: sunColor),
        const SizedBox(width: baseIconTextGap),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(temperature, style: tempStyle),
            const SizedBox(height: baseTempCityGap),
            Text(city, style: cityStyle),
          ],
        ),
      ],
    );

    return Transform.translate(
      offset: Offset(-shiftLeft * blockScale, 0),
      child: Transform.scale(
        scale: blockScale,
        alignment: Alignment.bottomRight,
        child: content,
      ),
    );
  }
}
