import 'package:flutter/material.dart';

import '../../../../core/services/user_service.dart';
import '../../../../theme/app_spacing.dart';

/// Resumen «N eventos · M tareas pendientes» para el saludo temporal (v0.48.41).
String homeEphemeralGreetingSummary({
  required int eventCount,
  required int taskCount,
}) {
  if (eventCount == 0 && taskCount == 0) {
    return 'Nada pendiente para hoy';
  }

  final parts = <String>[];
  if (eventCount > 0) {
    parts.add(
      eventCount == 1 ? '1 evento' : '$eventCount eventos',
    );
  }
  if (taskCount > 0) {
    parts.add(
      taskCount == 1
          ? '1 tarea pendiente'
          : '$taskCount tareas pendientes',
    );
  }
  return parts.join(' · ');
}

/// Bloque temporal: saludo, resumen y clima (sin fecha; v0.48.41).
class HomeEphemeralGreetingHeader extends StatelessWidget {
  const HomeEphemeralGreetingHeader({
    super.key,
    required this.eventCount,
    required this.taskCount,
    this.onTap,
  });

  final int eventCount;
  final int taskCount;
  final VoidCallback? onTap;

  // TODO: conectar clima real en una versión posterior.
  static const String _mockTemperature = '21°';
  static const String _mockCity = 'Madrid';

  static const double _greetingToSummaryGap = 4;
  static const double _weatherIconSize = 26;
  static const double _weatherIconTextGap = 6;
  static const double _weatherTempCityGap = 1;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final summaryStyle = TextStyle(
      fontSize: 13.5,
      height: 1.2,
      fontWeight: FontWeight.w400,
      color: scheme.onSurfaceVariant,
    );
    final greetingStyle = TextStyle(
      fontSize: 24,
      height: 1.08,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      color: scheme.onSurface,
    );
    final tempStyle = TextStyle(
      fontSize: 14.5,
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

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.homePageMarginH,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
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
              const SizedBox(width: 6),
              _WeatherGreetingBlock(
                temperature: _mockTemperature,
                city: _mockCity,
                iconSize: _weatherIconSize,
                iconTextGap: _weatherIconTextGap,
                tempCityGap: _weatherTempCityGap,
                tempStyle: tempStyle,
                cityStyle: cityStyle,
                iconColor: scheme.onSurfaceVariant.withValues(
                  alpha: isDark ? 0.88 : 0.78,
                ),
              ),
            ],
          ),
          const SizedBox(height: _greetingToSummaryGap),
          Text(
            homeEphemeralGreetingSummary(
              eventCount: eventCount,
              taskCount: taskCount,
            ),
            style: summaryStyle,
          ),
        ],
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: content,
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
    required this.iconColor,
  });

  final String temperature;
  final String city;
  final double iconSize;
  final double iconTextGap;
  final double tempCityGap;
  final TextStyle tempStyle;
  final TextStyle cityStyle;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Icon(
          Icons.wb_cloudy_rounded,
          size: iconSize,
          color: iconColor,
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
