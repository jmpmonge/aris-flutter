import 'package:flutter/material.dart';

import '../../../../core/services/user_service.dart';
import '../../../../shared/widgets/home_weather_icon.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';

/// Bloque superior: saludo + clima (sin resumen dinámico; v0.48.45 → Aris).
class HomeEphemeralGreetingHeader extends StatelessWidget {
  const HomeEphemeralGreetingHeader({super.key});

  // TODO: conectar clima real en una versión posterior.
  static const String _mockTemperature = '21°';
  static const String _mockCity = 'Madrid';

  static const double _weatherIconSize = 42;
  static const double _weatherBlockShiftLeft = 5;
  static const double _weatherIconTextGap = 8;
  static const double _weatherTempCityGap = 3;

  static const Color _sunTintLight = Color(0xFFF0A830);
  static const Color _sunTintDark = Color(0xFFE8C547);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final greetingStyle = TextStyle(
      fontSize: 26,
      height: 1.06,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.35,
      color: isDark ? AppColors.textPrimaryDark : scheme.onSurface,
    );
    final tempStyle = TextStyle(
      fontSize: 17.5,
      height: 1.05,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    );
    final cityStyle = TextStyle(
      fontSize: 11,
      height: 1.05,
      fontWeight: FontWeight.w400,
      color: scheme.onSurfaceVariant.withValues(alpha: isDark ? 0.70 : 0.65),
    );

    final cloudColor = scheme.onSurfaceVariant.withValues(
      alpha: isDark ? 0.88 : 0.78,
    );
    final sunColor = isDark ? _sunTintDark : _sunTintLight;

    final inner = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            UserService.getHomeGreetingShort(),
            style: greetingStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Transform.translate(
          offset: const Offset(-_weatherBlockShiftLeft, 0),
          child: _WeatherGreetingBlock(
            temperature: _mockTemperature,
            city: _mockCity,
            iconSize: _weatherIconSize,
            iconTextGap: _weatherIconTextGap,
            tempCityGap: _weatherTempCityGap,
            tempStyle: tempStyle,
            cityStyle: cityStyle,
            cloudColor: cloudColor,
            sunColor: sunColor,
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.homePageMarginH,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.homeCardPadding,
        ),
        child: inner,
      ),
    );
  }
}

/// Clima compacto: icono a la izquierda; grados y ciudad apilados (v0.48.41).
class _WeatherGreetingBlock extends StatelessWidget {
  const _WeatherGreetingBlock({
    required this.temperature,
    required this.city,
    required this.iconSize,
    required this.iconTextGap,
    required this.tempCityGap,
    required this.tempStyle,
    required this.cityStyle,
    required this.cloudColor,
    required this.sunColor,
  });

  final String temperature;
  final String city;
  final double iconSize;
  final double iconTextGap;
  final double tempCityGap;
  final TextStyle tempStyle;
  final TextStyle cityStyle;
  final Color cloudColor;
  final Color sunColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        HomeWeatherIcon(
          size: iconSize,
          cloudColor: cloudColor,
          sunColor: sunColor,
        ),
        SizedBox(width: iconTextGap),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(temperature, style: tempStyle),
            SizedBox(height: tempCityGap),
            Text(city, style: cityStyle),
          ],
        ),
      ],
    );
  }
}
