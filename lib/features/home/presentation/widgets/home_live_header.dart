import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/services/user_service.dart';
import '../../../../shared/widgets/home_weather_icon.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import 'home_greeting_session.dart';

const _kWeatherIconLarge = 38.0;
const _kWeatherIconCompact = 20.0;
const _kWeatherTempLarge = 17.5;
const _kWeatherTempCompact = 19.0;
const _kWeatherCityCompact = 11.5;
const _kWeatherBlockShiftLeft = 5.0;
const _kSunTintLight = Color(0xFFF0A830);
const _kSunTintDark = Color(0xFFE8C547);
const _kMockTemperature = '21°';
const _kMockCity = 'Madrid';

/// Cabecera viva de Home: saludo temporal + clima que colapsa (v0.49.35).
class HomeLiveHeader extends StatefulWidget {
  const HomeLiveHeader({super.key});

  @override
  State<HomeLiveHeader> createState() => _HomeLiveHeaderState();
}

class _HomeLiveHeaderState extends State<HomeLiveHeader>
    with TickerProviderStateMixin {
  static const Duration _visibleDuration = Duration(seconds: 7);
  static const Duration _fadeInDuration = Duration(milliseconds: 300);
  static const Duration _collapseDuration = Duration(milliseconds: 600);

  AnimationController? _fadeInController;
  AnimationController? _collapseController;
  Timer? _holdTimer;

  bool get _startCompact => HomeGreetingSession.hasReachedCompactMode;

  @override
  void initState() {
    super.initState();
    if (_startCompact) return;

    _fadeInController = AnimationController(
      vsync: this,
      duration: _fadeInDuration,
    );
    _collapseController = AnimationController(
      vsync: this,
      duration: _collapseDuration,
    );

    _fadeInController!.forward();
    _holdTimer = Timer(_visibleDuration, _beginCollapse);
  }

  void _beginCollapse() {
    if (!mounted || _collapseController == null) return;
    _collapseController!.forward().then((_) {
      if (mounted) {
        HomeGreetingSession.markCompactReached();
      }
    });
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _fadeInController?.dispose();
    _collapseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final sunColor = isDark ? _kSunTintDark : _kSunTintLight;
    final date = UserService.getHomeFixedDateLine();

    if (_startCompact) {
      return _HeaderShell(
        child: _CompactHeaderRow(
          date: date,
          temperature: _kMockTemperature,
          city: _kMockCity,
          sunColor: sunColor,
          scheme: scheme,
          isDark: isDark,
          compactProgress: 1,
        ),
      );
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _fadeInController!,
        _collapseController!,
      ]),
      builder: (context, _) {
        final fadeIn = Curves.easeOutCubic.transform(_fadeInController!.value);
        final collapse = Curves.easeInOutCubic.transform(
          _collapseController!.value,
        );
        final greetingOpacity = (1 - collapse) * fadeIn;
        final greetingSlide = 6 * (1 - fadeIn) + (-6 * collapse);

        return _HeaderShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _CompactHeaderRow(
                date: date,
                temperature: _kMockTemperature,
                city: _kMockCity,
                sunColor: sunColor,
                scheme: scheme,
                isDark: isDark,
                compactProgress: collapse,
              ),
              ClipRect(
                child: Align(
                  alignment: Alignment.topLeft,
                  heightFactor: (1 - collapse).clamp(0, 1),
                  child: Opacity(
                    opacity: greetingOpacity.clamp(0, 1),
                    child: Transform.translate(
                      offset: Offset(0, greetingSlide),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: AppSpacing.homeFixedDateToEphemeralGap,
                          bottom: collapse < 1 ? AppSpacing.xxs : 0,
                        ),
                        child: _ExpandedGreetingRow(
                          greeting: UserService.getGreetingForNow(),
                          temperature: _kMockTemperature,
                          city: _kMockCity,
                          sunColor: sunColor,
                          scheme: scheme,
                          isDark: isDark,
                          weatherOpacity: (1 - collapse).clamp(0, 1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderShell extends StatelessWidget {
  const _HeaderShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.homeFixedDateLeftInsetH,
        AppSpacing.homeFixedDateTopGap,
        AppSpacing.homePageMarginH,
        AppSpacing.homeFixedDateMinPadding,
      ),
      child: child,
    );
  }
}

/// Fila superior: fecha izquierda + mini-bloque clima derecha al colapsar.
class _CompactHeaderRow extends StatelessWidget {
  const _CompactHeaderRow({
    required this.date,
    required this.temperature,
    required this.city,
    required this.sunColor,
    required this.scheme,
    required this.isDark,
    required this.compactProgress,
  });

  final String date;
  final String temperature;
  final String city;
  final Color sunColor;
  final ColorScheme scheme;
  final bool isDark;
  final double compactProgress;

  @override
  Widget build(BuildContext context) {
    final dateSize = 12.0 + (2.5 * compactProgress.clamp(0, 1));
    final dateColor = isDark
        ? AppColors.textSecondaryDark.withValues(alpha: 0.88)
        : AppColors.textSecondaryLight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            date,
            style: TextStyle(
              fontSize: dateSize,
              height: 1.2,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.1,
              color: dateColor,
            ),
          ),
        ),
        if (compactProgress > 0.001) ...[
          const SizedBox(width: 12),
          Opacity(
            opacity: compactProgress.clamp(0, 1),
            child: Transform.translate(
              offset: Offset(0, 34 * (1 - compactProgress)),
              child: Transform.scale(
                scale: 0.88 + (0.12 * compactProgress),
                alignment: Alignment.topRight,
                child: _CompactWeatherBlock(
                  temperature: temperature,
                  city: city,
                  sunColor: sunColor,
                  scheme: scheme,
                  isDark: isDark,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Mini-bloque clima superior derecho (v0.49.35).
class _CompactWeatherBlock extends StatelessWidget {
  const _CompactWeatherBlock({
    required this.temperature,
    required this.city,
    required this.sunColor,
    required this.scheme,
    required this.isDark,
  });

  final String temperature;
  final String city;
  final Color sunColor;
  final ColorScheme scheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final tempStyle = TextStyle(
      fontSize: _kWeatherTempCompact,
      height: 1.05,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    );
    final cityStyle = TextStyle(
      fontSize: _kWeatherCityCompact,
      height: 1.05,
      fontWeight: FontWeight.w400,
      color: scheme.onSurfaceVariant.withValues(alpha: isDark ? 0.68 : 0.62),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HomeWeatherIcon(size: _kWeatherIconCompact, sunColor: sunColor),
            const SizedBox(width: 5),
            Text(temperature, style: tempStyle),
          ],
        ),
        const SizedBox(height: 2),
        Text(city, style: cityStyle),
      ],
    );
  }
}

class _ExpandedGreetingRow extends StatelessWidget {
  const _ExpandedGreetingRow({
    required this.greeting,
    required this.temperature,
    required this.city,
    required this.sunColor,
    required this.scheme,
    required this.isDark,
    this.weatherOpacity = 1,
  });

  final String greeting;
  final String temperature;
  final String city;
  final Color sunColor;
  final ColorScheme scheme;
  final bool isDark;
  final double weatherOpacity;

  @override
  Widget build(BuildContext context) {
    final greetingStyle = TextStyle(
      fontSize: 26,
      height: 1.06,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.35,
      color: isDark ? AppColors.textPrimaryDark : scheme.onSurface,
    );
    final tempStyle = TextStyle(
      fontSize: _kWeatherTempLarge,
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            greeting,
            style: greetingStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Opacity(
          opacity: weatherOpacity.clamp(0, 1),
          child: Transform.translate(
            offset: const Offset(-_kWeatherBlockShiftLeft, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                HomeWeatherIcon(
                  size: _kWeatherIconLarge,
                  sunColor: sunColor,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(temperature, style: tempStyle),
                    const SizedBox(height: 3),
                    Text(city, style: cityStyle),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
