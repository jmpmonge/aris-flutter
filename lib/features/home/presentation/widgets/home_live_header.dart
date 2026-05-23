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

/// Altura nominal del bloque clima a escala 1 (icono + ciudad).
const _kWeatherBlockNominalHeight = 38.0;

/// Cabecera viva de Home: saludo temporal + clima que colapsa (v0.49.53).
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

  double _collapseT() {
    if (_collapseController == null) return 0;
    return Curves.easeInOutCubic
        .transform(_collapseController!.value)
        .clamp(0.0, 1.0);
  }

  void _syncCollapseProgress() {
    HomeGreetingSession.collapseProgress.value = _collapseT();
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

  double _headerBottomPadding(double collapseT) {
    return lerpDouble(
      AppSpacing.homeLiveHeaderBottomWithGreeting,
      AppSpacing.homeLiveHeaderBottomCompact,
      collapseT,
    )!;
  }

  double _greetingSlotHeight(double collapseT) {
    return lerpDouble(AppSpacing.homeGreetingSlotHeight, 0, collapseT)!;
  }

  double _weatherTop(
    double collapseT,
    double dateFontSize,
    double weatherBlockScale,
  ) {
    final dateRowHeight = dateFontSize * 1.2;
    final weatherHeight = _kWeatherBlockNominalHeight * weatherBlockScale;
    final expandedTop =
        dateRowHeight + AppSpacing.homeGreetingSlotHeight - weatherHeight;
    return lerpDouble(expandedTop, 0, collapseT)!;
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
        final collapseT = _collapseT();
        final greetingOpacity = (1 - collapseT) * fadeIn;
        final greetingSlide = 4 * (1 - fadeIn);
        final dateFontSize = lerpDouble(12.0, 14.5, collapseT)!;
        final weatherBlockScale = lerpDouble(
          1.0,
          HomeWeatherBlock.weatherBlockCompactScale,
          collapseT,
        )!;
        final greetingHeight = _greetingSlotHeight(collapseT);
        final weatherTop = _weatherTop(collapseT, dateFontSize, weatherBlockScale);

        return _HeaderShell(
          bottomPadding: _headerBottomPadding(collapseT),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DateRow(
                    date: date,
                    dateFontSize: dateFontSize,
                    isDark: isDark,
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
                              child: _GreetingText(
                                greeting: UserService.getGreetingForNow(),
                                isDark: isDark,
                                scheme: scheme,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 0,
                top: weatherTop,
                child: HomeWeatherBlock(
                  temperature: _kMockTemperature,
                  city: _kMockCity,
                  sunColor: sunColor,
                  scheme: scheme,
                  isDark: isDark,
                  weatherBlockScale: weatherBlockScale,
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

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.date,
    required this.dateFontSize,
    required this.isDark,
  });

  final String date;
  final double dateFontSize;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final dateColor = isDark
        ? AppColors.textSecondaryDark.withValues(alpha: 0.88)
        : AppColors.textSecondaryLight;

    return Text(
      date,
      style: TextStyle(
        fontSize: dateFontSize,
        height: 1.2,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        color: dateColor,
      ),
    );
  }
}

/// Fila compacta final: fecha + clima (estado estable tras colapso).
class _CompactHeaderRow extends StatelessWidget {
  const _CompactHeaderRow({
    required this.date,
    required this.temperature,
    required this.city,
    required this.sunColor,
    required this.scheme,
    required this.isDark,
  });

  final String date;
  final String temperature;
  final String city;
  final Color sunColor;
  final ColorScheme scheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
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
              fontSize: 14.5,
              height: 1.2,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.1,
              color: dateColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        HomeWeatherBlock(
          temperature: temperature,
          city: city,
          sunColor: sunColor,
          scheme: scheme,
          isDark: isDark,
          weatherBlockScale: HomeWeatherBlock.weatherBlockCompactScale,
        ),
      ],
    );
  }
}

class _GreetingText extends StatelessWidget {
  const _GreetingText({
    required this.greeting,
    required this.isDark,
    required this.scheme,
  });

  final String greeting;
  final bool isDark;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      greeting,
      style: TextStyle(
        fontSize: 26,
        height: 1.06,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.35,
        color: isDark ? AppColors.textPrimaryDark : scheme.onSurface,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
