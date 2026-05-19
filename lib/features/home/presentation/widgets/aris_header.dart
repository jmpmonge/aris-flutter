import 'package:flutter/material.dart';

import '../../../../core/services/user_service.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';

/// Cabecera Home diario — fecha + saludo + insight opcional + avatar (sin wordmark «aris»).
class ArisHeader extends StatelessWidget {
  const ArisHeader({
    super.key,
    this.onAssistantTap,
    this.contextualInsight,
    this.showDateAndGreeting = true,
    this.compactTrailingOnly = false,
  });

  /// Conserva el gesto previo (p. ej. abrir asistente / perfil).
  final VoidCallback? onAssistantTap;

  /// Solo si hay sugerencia real (eventos/tareas); null = sin texto de relleno.
  final String? contextualInsight;

  /// Si false, solo avatar (insight en tarjeta superior descartable; v0.48.32).
  final bool showDateAndGreeting;

  /// Solo avatar, sin padding exterior (fila fecha+avatar en Home; v0.48.37).
  final bool compactTrailingOnly;

  static const double _paddingTop = 12;
  static const double _dateGreetingGap = 4;
  static const double _greetingInsightGap = 6;
  static const double _avatarSize = 40;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = UserService.getCurrentUser();

    final dateStyle = TextStyle(
      fontSize: 13.5,
      height: 1.2,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: isDark
          ? const Color(0xFFC3CAD6)
          : AppColors.textSecondaryLight,
    );

    final greetingStyle = TextStyle(
      fontSize: 28,
      height: 1.08,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      color: isDark ? const Color(0xFFE8ECF4) : AppColors.primaryDeep,
    );

    final insightStyle = TextStyle(
      fontSize: 14,
      height: 1.35,
      fontWeight: FontWeight.w400,
      color: isDark
          ? const Color(0xFFC3CAD6)
          : scheme.onSurfaceVariant,
    );

    final column = showDateAndGreeting
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(UserService.getHomeDateLine(), style: dateStyle),
              const SizedBox(height: _dateGreetingGap),
              Text(UserService.getHomeGreetingShort(), style: greetingStyle),
              if (contextualInsight != null &&
                  contextualInsight!.trim().isNotEmpty) ...[
                const SizedBox(height: _greetingInsightGap),
                Text(
                  contextualInsight!.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: insightStyle,
                ),
              ],
            ],
          )
        : const SizedBox.shrink();

    final avatar = Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.primaryContainer,
        border: Border.all(
          color: scheme.outline.withValues(alpha: isDark ? 0.28 : 0.14),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        user.primaryInitial.toUpperCase(),
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );

    if (compactTrailingOnly) {
      return _buildAvatarTapTarget(avatar);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.homePageMarginH,
        _paddingTop,
        AppSpacing.homePageMarginH,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: column),
          const SizedBox(width: 12),
          _buildAvatarTapTarget(avatar),
        ],
      ),
    );
  }

  Widget _buildAvatarTapTarget(Widget avatar) {
    if (onAssistantTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onAssistantTap,
          customBorder: const CircleBorder(),
          child: avatar,
        ),
      );
    }
    return avatar;
  }
}
