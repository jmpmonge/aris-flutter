import 'package:flutter/material.dart';

import '../../../../shared/widgets/home_weather_icon.dart';

/// Bloque de clima escalable para Home (v0.49.50).
///
/// Misma composición en todos los estados: icono · grados · ciudad debajo.
/// [scale] reduce proporcionalmente icono, tipografías y separaciones.
/// [sunIconScale] solo afecta al icono del sol, centrado en su caja fija.
class HomeWeatherBlock extends StatelessWidget {
  const HomeWeatherBlock({
    super.key,
    required this.temperature,
    required this.city,
    required this.sunColor,
    required this.scheme,
    required this.isDark,
    this.scale = 1,
    this.sunIconScale = 1,
    this.shiftLeft = 5.0,
  });

  static const double compactScale = 0.78;

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
  final double scale;
  final double sunIconScale;
  final double shiftLeft;

  @override
  Widget build(BuildContext context) {
    final double s = scale.clamp(0.01, 1.5);
    final iconSize = baseIconSize * s;
    final tempSize = baseTemperatureFontSize * s;
    final citySize = baseCityFontSize * s;
    final iconGap = baseIconTextGap * s;
    final cityGap = baseTempCityGap * s;

    final tempStyle = TextStyle(
      fontSize: tempSize,
      height: 1.05,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    );
    final cityStyle = TextStyle(
      fontSize: citySize,
      height: 1.05,
      fontWeight: FontWeight.w400,
      color: scheme.onSurfaceVariant.withValues(alpha: isDark ? 0.70 : 0.65),
    );

    return Transform.translate(
      offset: Offset(-shiftLeft * s, 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: Center(
              child: Transform.scale(
                scale: sunIconScale.clamp(0.01, 2.0),
                alignment: Alignment.center,
                child: HomeWeatherIcon(size: iconSize, sunColor: sunColor),
              ),
            ),
          ),
          SizedBox(width: iconGap),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(temperature, style: tempStyle),
              SizedBox(height: cityGap),
              Text(city, style: cityStyle),
            ],
          ),
        ],
      ),
    );
  }
}
