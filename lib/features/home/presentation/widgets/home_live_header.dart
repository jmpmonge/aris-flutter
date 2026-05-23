import 'dart:async';

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

/// Cabecera viva de Home: saludo temporal + clima que colapsa (v0.49.46).
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
  static const Duration _sunPulseDuration = Duration(milliseconds: 150);

  AnimationController? _fadeInController;
  AnimationController? _collapseController;
  AnimationController? _sunPulseController;
  Animation<double>? _sunPulseScale;
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
    _sunPulseController = AnimationController(
      vsync: this,
      duration: _sunPulseDuration,
    );
    _sunPulseScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 1.03)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.03, end: 1)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 55,
      ),
    ]).animate(_sunPulseController!);

    _collapseController!.addStatusListener(_onCollapseStatus);

    _fadeInController!.forward();
    _holdTimer = Timer(_visibleDuration, _beginCollapse);
  }

  void _onCollapseStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      _sunPulseController?.forward(from: 0);
    }
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
    _collapseController?.removeStatusListener(_onCollapseStatus);
    _fadeInController?.dispose();
    _collapseController?.dispose();
    _sunPulseController?.dispose();
    super.dispose();
  }

  double _weatherScale(double collapse) {
    return HomeWeatherBlock.compactScale +
        (1 - HomeWeatherBlock.compactScale) * (1 - collapse);
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
          compactProgress: 1,
          weatherScale: HomeWeatherBlock.compactScale,
        ),
      );
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _fadeInController!,
        _collapseController!,
        ?_sunPulseController,
      ]),
      builder: (context, _) {
        final fadeIn = Curves.easeOutCubic.transform(_fadeInController!.value);
        final collapse = Curves.easeInOutCubic.transform(
          _collapseController!.value,
        );
        final greetingOpacity = (1 - collapse) * fadeIn;
        final greetingSlide = 4 * (1 - fadeIn);
        final weatherScale = _weatherScale(collapse);
        final iconExtraScale = _collapseController!.isCompleted
            ? (_sunPulseScale?.value ?? 1.0)
            : 1.0;

        return _HeaderShell(
          bottomPadding: AppSpacing.homeLiveHeaderBottomWithGreeting +
              (AppSpacing.homeLiveHeaderBottomCompact -
                      AppSpacing.homeLiveHeaderBottomWithGreeting) *
                  collapse,
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
                weatherScale: weatherScale,
                iconExtraScale: iconExtraScale,
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
                        padding: const EdgeInsets.only(
                          top: AppSpacing.homeFixedDateToEphemeralGap,
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
        AppSpacing.homeFixedDateLeftInsetH,
        AppSpacing.homeFixedDateTopGap,
        AppSpacing.homePageMarginH,
        bottomPadding,
      ),
      child: child,
    );
  }
}

/// Fila superior: fecha izquierda + clima escalado a la derecha al colapsar.
class _CompactHeaderRow extends StatelessWidget {
  const _CompactHeaderRow({
    required this.date,
    required this.temperature,
    required this.city,
    required this.sunColor,
    required this.scheme,
    required this.isDark,
    required this.compactProgress,
    required this.weatherScale,
    this.iconExtraScale = 1.0,
  });

  final String date;
  final String temperature;
  final String city;
  final Color sunColor;
  final ColorScheme scheme;
  final bool isDark;
  final double compactProgress;
  final double weatherScale;
  final double iconExtraScale;

  @override
  Widget build(BuildContext context) {
    final t = compactProgress.clamp(0.0, 1.0);
    final dateSize = 12.0 + (2.5 * t);
    final dateColor = isDark
        ? AppColors.textSecondaryDark.withValues(alpha: 0.88)
        : AppColors.textSecondaryLight;
    final weatherRise = Curves.easeOutCubic.transform(t);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 2 * t),
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
        ),
        if (t > 0.001) ...[
          const SizedBox(width: 12),
          Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, 36 * (1 - weatherRise)),
              child: Padding(
                padding: const EdgeInsets.only(top: 1, right: 2),
                child: HomeWeatherBlock(
                  temperature: temperature,
                  city: city,
                  sunColor: sunColor,
                  scheme: scheme,
                  isDark: isDark,
                  scale: weatherScale,
                  iconExtraScale: iconExtraScale,
                ),
              ),
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
          child: HomeWeatherBlock(
            temperature: temperature,
            city: city,
            sunColor: sunColor,
            scheme: scheme,
            isDark: isDark,
            scale: 1,
          ),
        ),
      ],
    );
  }
}
