import 'package:flutter/material.dart';

import '../../../shared/widgets/app_card.dart';
import '../../../theme/app_spacing.dart';

/// Ajustes — interruptores y enlaces **sin efecto real**.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text('Apariencia', style: text.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          SwitchListTile(
            title: const Text('Seguir tema del sistema'),
            subtitle: const Text('Recomendado en iOS (mock, siempre activo)'),
            value: true,
            onChanged: (_) {},
          ),
          SwitchListTile(
            title: const Text('Reducir movimiento'),
            subtitle: const Text('Menos animaciones (no conectado)'),
            value: false,
            onChanged: (_) {},
          ),
          const Divider(height: AppSpacing.xl),
          Text('Clara / voz', style: text.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          SwitchListTile(
            title: const Text('Sugerencias de voz'),
            subtitle: const Text('Sin micrófono real en esta versión'),
            value: false,
            onChanged: (_) {},
          ),
          ListTile(
            leading: Icon(Icons.record_voice_over_outlined, color: scheme.primary),
            title: const Text('Tonos de respuesta'),
            subtitle: const Text('Amable · Directa · Profesional (mock)'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          const Divider(height: AppSpacing.xl),
          Text('Privacidad y cuenta', style: text.titleSmall),
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
                  title: Text('Cerrar sesión', style: TextStyle(color: scheme.error)),
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
