import 'package:flutter/material.dart';

import '../../../core/models/app_theme_mode.dart';
import '../../../core/repositories/repositories.dart';
import '../../../core/services/backend_reads_caption.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../theme/app_spacing.dart';
import 'backend_status_section.dart';

/// Ajustes — apariencia real + opciones **sin efecto backend**.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          Text(
            'Apariencia',
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Elige cómo se ve Aris en este dispositivo.',
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: Repositories.settings.themeListenable,
            builder: (context, mode, _) {
              return AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: const Icon(Icons.light_mode_outlined, size: 18),
                          label: Text(AppThemePreference.light.labelEs),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: const Icon(Icons.dark_mode_outlined, size: 18),
                          label: Text(AppThemePreference.dark.labelEs),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: const Icon(
                            Icons.brightness_auto_outlined,
                            size: 18,
                          ),
                          label: Text(AppThemePreference.system.labelEs),
                        ),
                      ],
                      selected: {mode},
                      onSelectionChanged: (Set<ThemeMode> next) {
                        if (next.isEmpty) return;
                        Repositories.settings.setThemeMode(next.first);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      mode == ThemeMode.system
                          ? 'Aris seguirá el tema claro u oscuro del sistema.'
                          : mode == ThemeMode.dark
                              ? 'Modo oscuro con azules profundos y buen contraste.'
                              : 'Modo claro con fondos crema y acentos azul‑violeta.',
                      style: text.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: AppSpacing.xl),
          Text(
            'Animación (demo)',
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          SwitchListTile(
            title: const Text('Reducir movimiento'),
            subtitle: const Text('Menos animaciones (no conectado)'),
            value: false,
            onChanged: (_) {},
          ),
          const Divider(height: AppSpacing.xl),
          Text(
            'Aris / voz',
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          SwitchListTile(
            title: const Text('Sugerencias de voz'),
            subtitle: const Text('Sin micrófono real en esta versión'),
            value: false,
            onChanged: (_) {},
          ),
          ListTile(
            leading: Icon(
              Icons.record_voice_over_outlined,
              color: scheme.primary,
            ),
            title: const Text('Tonos de respuesta'),
            subtitle: const Text('Amable · Directa · Profesional (mock)'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          const Divider(height: AppSpacing.xl),
          Text(
            'Servidor FastAPI (desarrollo)',
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Comprueba si el backend local responde en el puerto 8000. '
            'Las lecturas GET pueden rellenar listas; si no hay servidor, '
            'Aris usa datos locales de demostración.',
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          const BackendStatusSection(),
          Text(
            'Origen mostrado (solo lecturas GET)',
            style: text.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          ValueListenableBuilder<String>(
            valueListenable: backendReadsCaption,
            builder: (context, caption, _) {
              return Text(
                caption,
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              );
            },
          ),
          const Divider(height: AppSpacing.xl),
          Text(
            'Privacidad y cuenta',
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppCard(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Exportar mis datos'),
                  subtitle: const Text('Simulación · no genera archivo'),
                  trailing: const Icon(Icons.download_outlined),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(
                    'Cerrar sesión',
                    style: TextStyle(color: scheme.error),
                  ),
                  subtitle: const Text('Sin sesión real aún'),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
