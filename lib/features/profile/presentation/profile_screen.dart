import 'package:flutter/material.dart';

import '../../../core/app_meta.dart';
import '../../../core/icon_from_key.dart';
import '../../../core/services/user_service.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../theme/app_spacing.dart';
import '../../mail/presentation/mail_screen.dart';
import '../../settings/presentation/settings_screen.dart';

/// Perfil — cuenta, categorías amplias y acerca de (v0.49.25).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _openAccountMock(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cuenta · solo mock')),
    );
  }

  void _onMenuTap(BuildContext context, String title) {
    if (title == 'Conexiones') {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => const MailScreen()),
      );
      return;
    }
    if (title == 'Preferencias') {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title · solo mock')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final user = UserService.getCurrentUser();
    final options = UserService.getProfileMenuEntries();

    return SafeArea(
      top: true,
      bottom: false,
      child: ListView(
        key: const Key('tab_profile'),
        padding: const EdgeInsets.only(bottom: AppSpacing.fabStackClearance),
        children: [
          const AppHeader(title: 'Perfil', subtitle: 'Tu espacio en Aris'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: AppCard(
              onTap: () => _openAccountMock(context),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: AppSpacing.profileAvatarRadius,
                    backgroundColor: scheme.primaryContainer,
                    child: Text(
                      user.primaryInitial,
                      style: text.headlineSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.displayName, style: text.titleMedium),
                        Text(
                          'Cuenta local simulada',
                          style: text.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.emailSimulated,
                          style: text.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant.withValues(
                              alpha: 0.85,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...options.map(
            (o) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xxs,
              ),
              child: AppCard(
                onTap: () => _onMenuTap(context, o.title),
                child: Row(
                  children: [
                    Icon(iconFromKey(o.iconKey), color: scheme.primary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(o.title, style: text.titleSmall),
                          Text(
                            o.subtitle,
                            style: text.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: AppCard(
              onTap: () => _onMenuTap(context, 'Acerca de Aris'),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: scheme.primary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Acerca de Aris', style: text.titleSmall),
                        Text(
                          'Versión, cambios y estado',
                          style: text.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          AppMeta.userVisibleVersionLine,
                          style: text.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant.withValues(
                              alpha: 0.9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
