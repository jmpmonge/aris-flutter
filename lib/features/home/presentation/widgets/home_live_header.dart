import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../../../core/services/user_service.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import 'home_greeting_session.dart';
import 'home_weather_block.dart';

const _kSunTintLight = Color(0xFFF0A830);
const _kSunTintDark = Color(0xFFE8C547);
const _kMockTemperature = '21°';
const _kMockCity = 'Madrid';
const _kWeatherBlockRiseOffset = 36.0;

/// Cabecera viva de Home: saludo temporal + clima que colapsa (v0.49.51).
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

  /// Fracción inicial reservada solo a animación visual (sin mover HOY).
  static const double _kLayoutDelay = 0.45;

  AnimationController? _fadeInController;
  AnimationController? _collapseController;
  Timer? _holdTimer;

  bool get _startCompact => HomeGreetingSession.hasReachedCompactMode;

  @override
  void initState() {
    super.initState();
    if (_startCompact) {
      HomeGreetingSession.collapseProgress.value = 1;
      return;
    }

    _fadeInController = AnimationController(
      vsync: this,
      duration: _fadeInDuration,
    );
    _collapseController = AnimationController(
      vsync: this,
      duration: _collapseDuration,
    );

    _fadeInController!.forward();
    _collapseController!.addListener(_syncCollapseProgress);
    _holdTimer = Timer(_visibleDuration, _beginCollapse);
  }

  void _syncCollapseProgress() {
    if (_collapseController == null) return;
    final weatherBlockProgress = Curves.easeInOutCubic
        .transform(_collapseController!.value)
        .clamp(0.0, 1.0);
    HomeGreetingSession.collapseProgress.value =
        _layoutProgress(weatherBlockProgress);
  }

  double _layoutProgress(double weatherBlockProgress) {
    if (weatherBlockProgress <= _kLayoutDelay) return 0.0;
    return ((weatherBlockProgress - _kLayoutDelay) / (1.0 - _kLayoutDelay))
        .clamp(0.0, 1.0);
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
    _collapseController?.removeListener(_syncCollapseProgress);
    _fadeInController?.dispose();
    _collapseController?.dispose();
    super.dispose();
  }

  double _headerBottomPadding(double layoutT) {
    return lerpDouble(
      AppSpacing.homeLiveHeaderBottomWithGreeting,
      AppSpacing.homeLiveHeaderBottomCompact,
      layoutT,
    )!;
  }

  double _greetingSlotHeight(double layoutT) {
    return lerpDouble(AppSpacing.homeGreetingSlotHeight, 0, layoutT)!;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final sunColor = isDark ? _kSunTintDark : _kSunTintLight;
    final date = UserService.getHomeFixedDateLine();

    if (_startCompact) {
      return _HeaderShell(
        bottomPadding: AppSpacing.homeLiveHeaderBottomCompact,
        child: _CompactHeaderRow(
          date: date,
          temperature: _kMockTemperature,
          city: _kMockCity,
          sunColor: sunColor,
          scheme: scheme,
          isDark: isDark,
          layoutProgress: 1,
          weatherBlockScale: HomeWeatherBlock.weatherBlockCompactScale,
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
        final weatherBlockProgress = Curves.easeInOutCubic
            .transform(_collapseController!.value)
            .clamp(0.0, 1.0);
        final layoutT = _layoutProgress(weatherBlockProgress);
        final greetingOpacity = (1 - weatherBlockProgress) * fadeIn;
        final greetingSlide = 4 * (1 - fadeIn);
        final weatherBlockScale = lerpDouble(
          1.0,
          HomeWeatherBlock.weatherBlockCompactScale,
          weatherBlockProgress,
        )!;
        final greetingHeight = _greetingSlotHeight(layoutT);
        final showGreetingWeather = layoutT <= 0;

        return _HeaderShell(
          bottomPadding: _headerBottomPadding(layoutT),
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
                layoutProgress: layoutT,
                weatherBlockScale: weatherBlockScale,
              ),
              SizedBox(
                height: greetingHeight,
                child: ClipRect(
                  child: Opacity(
                    opacity: greetingOpacity.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, greetingSlide),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: AppSpacing.homeFixedDateToEphemeralGap,
                        ),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: _ExpandedGreetingRow(
                            greeting: UserService.getGreetingForNow(),
                            temperature: _kMockTemperature,
                            city: _kMockCity,
                            sunColor: sunColor,
                            scheme: scheme,
                            isDark: isDark,
                            showWeather: showGreetingWeather,
                            weatherBlockScale: weatherBlockScale,
                          ),
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
  const _HeaderShell({
    required this.child,
    required this.bottomPadding,
  });

  final Widget child;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.homeHeaderHorizontalInset,
        AppSpacing.homeFixedDateTopGap,
        AppSpacing.homeHeaderHorizontalInset,
        bottomPadding,
      ),
      child: child,
    );
  }
}

/// Fila superior: fecha izquierda + bloque clima a la derecha al colapsar.
class _CompactHeaderRow extends StatelessWidget {
  const _CompactHeaderRow({
    required this.date,
    required this.temperature,
    required this.city,
    required this.sunColor,
    required this.scheme,
    required this.isDark,
    required this.layoutProgress,
    required this.weatherBlockScale,
  });

  final String date;
  final String temperature;
  final String city;
  final Color sunColor;
  final ColorScheme scheme;
  final bool isDark;
  final double layoutProgress;
  final double weatherBlockScale;

  @override
  Widget build(BuildContext context) {
    final double layoutT = layoutProgress.clamp(0.0, 1.0);
    final dateSize = lerpDouble(12.0, 14.5, layoutT)!;
    final dateColor = isDark
        ? AppColors.textSecondaryDark.withValues(alpha: 0.88)
        : AppColors.textSecondaryLight;
    final weatherBlockOffsetY = lerpDouble(
      _kWeatherBlockRiseOffset,
      0.0,
      layoutT,
    )!;
    final rowCrossAxisAlignment = layoutT > 0.5
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;

    return Row(
      crossAxisAlignment: rowCrossAxisAlignment,
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
        if (layoutT > 0.001) ...[
          const SizedBox(width: 12),
          Transform.translate(
            offset: Offset(0, weatherBlockOffsetY),
            child: HomeWeatherBlock(
              temperature: temperature,
              city: city,
              sunColor: sunColor,
              scheme: scheme,
              isDark: isDark,
              weatherBlockScale: weatherBlockScale,
            ),
          ),
        ],
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
    this.showWeather = true,
    this.weatherBlockScale = 1,
  });

  final String greeting;
  final String temperature;
  final String city;
  final Color sunColor;
  final ColorScheme scheme;
  final bool isDark;
  final bool showWeather;
  final double weatherBlockScale;

  @override
  Widget build(BuildContext context) {
    final greetingStyle = TextStyle(
      fontSize: 26,
      height: 1.06,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.35,
      color: isDark ? AppColors.textPrimaryDark : scheme.onSurface,
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
        if (showWeather)
          HomeWeatherBlock(
            temperature: temperature,
            city: city,
            sunColor: sunColor,
            scheme: scheme,
            isDark: isDark,
            weatherBlockScale: weatherBlockScale,
          ),
      ],
    );
  }
}
