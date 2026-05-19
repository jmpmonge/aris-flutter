import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/prefs/home_suggestion_hint_prefs.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Tarjeta de sugerencia — modo claro sin cambios; v0.48.16 regularización solo oscuro.
class SuggestionCard extends StatelessWidget {
  const SuggestionCard({
    super.key,
    this.label = 'SUGERENCIA',
    required this.message,
    this.applyHorizontalMargin = true,
  });

  final String label;
  final String message;

  /// Si false, el padre aplica [AppSpacing.homePageMarginH] (p. ej. wrapper con InkWell).
  final bool applyHorizontalMargin;

  static const double cardHeight = 86;
  static const double cardRadius = AppSpacing.homeCardRadius;
  static const double padH = 14;

  /// Alineación del cuerpo con el título [label] (misma grilla que HOY/CHAT, v0.48.24).
  static double get bodyTextLeftFromInner =>
      AppSpacing.homeCardHeaderInkPaddingH +
      AppSpacing.homeCardHeaderIconSize +
      AppSpacing.homeCardHeaderIconTitleGap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final accentGreen = AppColors.suggestionGreen;
    final iconTint = isDark ? AppColors.suggestionGreenDark : accentGreen;

    final labelStyle = TextStyle(
      fontSize: 11.5,
      letterSpacing: 0.7,
      color: isDark ? AppColors.textPrimaryDark : AppColors.primaryDeep,
      fontWeight: FontWeight.w700,
      height: 1.0,
    );

    final bodyStyle = TextStyle(
      fontSize: 14.25,
      height: 1.24,
      fontWeight: FontWeight.w400,
      color: isDark ? AppColors.textSecondaryDark : scheme.onSurfaceVariant,
    );

    final cardColor =
        isDark ? scheme.surface : AppColors.suggestionSurfacePale;

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(
          color: scheme.outline.withValues(
            alpha: AppColors.homeCardBorderAlpha(
              isDark ? Brightness.dark : Brightness.light,
            ),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(
              alpha: AppColors.homeCardShadowAlpha(
                isDark ? Brightness.dark : Brightness.light,
              ),
            ),
            blurRadius: AppSpacing.shadowBlurHomeCard,
            offset: AppSpacing.shadowOffsetHomeCard,
          ),
        ],
      ),
      child: SizedBox(
        height: cardHeight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(padH, 8, padH, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.homeCardHeaderInkPaddingH,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: AppSpacing.homeCardHeaderIconSize,
                      color: iconTint,
                    ),
                    SizedBox(width: AppSpacing.homeCardHeaderIconTitleGap),
                    Text(label, style: labelStyle),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: EdgeInsets.only(left: bodyTextLeftFromInner),
                child: Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: bodyStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!applyHorizontalMargin) return card;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.homePageMarginH),
      child: card,
    );
  }
}

/// Colores y opacidad del pulso de pista (v0.48.40).
abstract final class _SuggestionHintPulseStyle {
  static const Color light = Color(0xFF2FAE68);
  static const Color dark = Color(0xFF8FE6B2);
  static const double opacityMaxLight = 0.20;
  static const double opacityMaxDark = 0.22;

  /// Halo máximo 36 px; núcleo en reposo ≈ 27.7 px (× 1.30 al pico).
  static const double haloMaxDiameter = 36;

  static const double pulseScaleMax = 1.30;

  static const double coreDiameter = haloMaxDiameter / pulseScaleMax;
}

/// Pista visual circular superior derecha (v0.48.40).
class _SuggestionCardHintPulse extends StatelessWidget {
  const _SuggestionCardHintPulse({
    required this.color,
    required this.maxOpacity,
    required this.scale,
    required this.opacityFactor,
  });

  final Color color;
  final double maxOpacity;
  final double scale;
  final double opacityFactor;

  @override
  Widget build(BuildContext context) {
    final alpha = maxOpacity * opacityFactor;
    if (alpha <= 0) return const SizedBox.shrink();

    return SizedBox(
      width: _SuggestionHintPulseStyle.haloMaxDiameter,
      height: _SuggestionHintPulseStyle.haloMaxDiameter,
      child: Center(
        child: Transform.scale(
          scale: scale,
          child: Container(
            width: _SuggestionHintPulseStyle.coreDiameter,
            height: _SuggestionHintPulseStyle.coreDiameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: alpha),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta SUGERENCIA con pista visual sutil (doble pulso derecha, v0.48.40).
class SuggestionCardWithFirstRunHint extends StatefulWidget {
  const SuggestionCardWithFirstRunHint({
    super.key,
    required this.label,
    required this.message,
    required this.onTap,
  });

  final String label;
  final String message;
  final VoidCallback onTap;

  @override
  State<SuggestionCardWithFirstRunHint> createState() =>
      SuggestionCardWithFirstRunHintState();
}

class SuggestionCardWithFirstRunHintState
    extends State<SuggestionCardWithFirstRunHint>
    with SingleTickerProviderStateMixin {
  static const Duration _initialDelay = Duration(milliseconds: 3000);
  static const Duration _pulseDuration = Duration(milliseconds: 1500);
  static const int _pulseCount = 2;

  late final AnimationController _pulseController;
  late final Animation<double> _haloScale;
  late final Animation<double> _haloOpacityFactor;

  bool _hintSequenceActive = false;
  bool _hintConsumed = false;
  Timer? _hintTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: _pulseDuration,
    );
    final curved = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutCubic,
    );
    _haloScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: _SuggestionHintPulseStyle.pulseScaleMax,
        ),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: _SuggestionHintPulseStyle.pulseScaleMax,
          end: 1.0,
        ),
        weight: 50,
      ),
    ]).animate(curved);
    _haloOpacityFactor = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 50),
    ]).animate(curved);
    _pulseController.addListener(() {
      if (mounted) setState(() {});
    });
    unawaited(_maybeRunFirstRunHint());
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> consumeHint() async {
    _hintTimer?.cancel();
    if (_hintConsumed) return;
    _hintConsumed = true;
    _hintSequenceActive = false;
    if (mounted) setState(() {});
    await HomeSuggestionHintPrefs.markHintSeen();
  }

  Future<void> _maybeRunFirstRunHint() async {
    if (await HomeSuggestionHintPrefs.hasSeenHint()) {
      _hintConsumed = true;
      return;
    }

    _hintSequenceActive = true;
    _hintTimer = Timer(_initialDelay, () {
      unawaited(_runHintSequence());
    });
  }

  Future<void> _runHintSequence() async {
    if (!mounted || _hintConsumed || !_hintSequenceActive) return;

    for (var i = 0; i < _pulseCount; i++) {
      await _pulseController.forward(from: 0);
      if (!mounted || _hintConsumed) return;
    }

    await consumeHint();
  }

  void _handleTap() {
    unawaited(consumeHint());
    widget.onTap();
  }

  static const double _hintRight = 20;
  static const double _hintTop = 18;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintColor = isDark
        ? _SuggestionHintPulseStyle.dark
        : _SuggestionHintPulseStyle.light;
    final hintOpacityMax = isDark
        ? _SuggestionHintPulseStyle.opacityMaxDark
        : _SuggestionHintPulseStyle.opacityMaxLight;

    final showHalo = !_hintConsumed && _hintSequenceActive;
    final haloScale = showHalo ? _haloScale.value : 1.0;
    final haloOpacityFactor =
        showHalo ? _haloOpacityFactor.value : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.homePageMarginH),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SuggestionCard.cardRadius),
        child: Material(
          color: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(SuggestionCard.cardRadius),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                SuggestionCard(
                  label: widget.label,
                  message: widget.message,
                  applyHorizontalMargin: false,
                ),
                Positioned(
                  right: _hintRight,
                  top: _hintTop,
                  child: IgnorePointer(
                    child: _SuggestionCardHintPulse(
                      color: hintColor,
                      maxOpacity: hintOpacityMax,
                      scale: haloScale,
                      opacityFactor: haloOpacityFactor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
