import 'package:flutter/material.dart';

import '../../../core/app_meta.dart';
import '../../../core/icon_from_key.dart';
import '../../../core/services/user_service.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../theme/app_spacing.dart';
import '../../settings/presentation/settings_screen.dart';

/// Perfil — usuario, opciones y **versión** (mock).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final user = UserService.getCurrentUser();
    final options = UserService.getProfileMenuEntries();

    return SafeArea(
      child: ListView(
        key: const Key('tab_profile'),
        padding: const EdgeInsets.only(bottom: AppSpacing.fabStackClearance),
        children: [
          const AppHeader(title: 'Perfil', subtitle: 'Tu espacio en Aris'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: AppCard(
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
                        Text(user.emailSimulated, style: text.bodySmall),
                      ],
                    ),
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
                onTap: () {
                  if (o.title == 'Cuenta') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cuenta · solo mock')),
                    );
                    return;
                  }
                  if (o.title == 'Preferencias') {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${o.title} · solo mock')),
                  );
                },
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Versión',
                    style: text.labelSmall?.copyWith(
                      color: scheme.secondary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppMeta.userVisibleVersionLine,
                    style: text.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
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
