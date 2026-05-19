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

/// Encabezado temporal sin tarjeta: fecha, saludo, resumen y clima compacto (v0.48.41).
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

  // Mock clima hasta conectar API (v0.48.41).
  static const String _mockTemperature = '21°';
  static const String _mockCity = 'Madrid';

  static const double _dateToGreetingGap = 8;
  static const double _greetingToSummaryGap = 4;
  static const double _weatherBlockWidth = 80;
  static const double _weatherIconTextGap = 6;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dateMuted = scheme.onSurfaceVariant.withValues(
      alpha: isDark ? 0.78 : 0.72,
    );
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
      fontSize: 14,
      height: 1.1,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    );
    final cityStyle = TextStyle(
      fontSize: 11,
      height: 1.1,
      fontWeight: FontWeight.w400,
      color: scheme.onSurfaceVariant.withValues(alpha: isDark ? 0.72 : 0.68),
    );

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.homePageMarginH,
        AppSpacing.homeHeaderTopGap,
        AppSpacing.homePageMarginH,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            UserService.getHomeFixedDateLine(),
            style: TextStyle(
              fontSize: 13,
              height: 1.15,
              fontWeight: FontWeight.w500,
              color: dateMuted,
            ),
          ),
          const SizedBox(height: _dateToGreetingGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              _WeatherCompact(
                temperature: _mockTemperature,
                city: _mockCity,
                blockWidth: _weatherBlockWidth,
                iconTextGap: _weatherIconTextGap,
                tempStyle: tempStyle,
                cityStyle: cityStyle,
                iconColor: scheme.onSurfaceVariant.withValues(
                  alpha: isDark ? 0.85 : 0.75,
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

class _WeatherCompact extends StatelessWidget {
  const _WeatherCompact({
    required this.temperature,
    required this.city,
    required this.blockWidth,
    required this.iconTextGap,
    required this.tempStyle,
    required this.cityStyle,
    required this.iconColor,
  });

  final String temperature;
  final String city;
  final double blockWidth;
  final double iconTextGap;
  final TextStyle tempStyle;
  final TextStyle cityStyle;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: blockWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wb_cloudy_rounded,
                size: 18,
                color: iconColor,
              ),
              SizedBox(width: iconTextGap),
              Text(temperature, style: tempStyle),
            ],
          ),
          Text(city, style: cityStyle, textAlign: TextAlign.right),
        ],
      ),
    );
  }
}
