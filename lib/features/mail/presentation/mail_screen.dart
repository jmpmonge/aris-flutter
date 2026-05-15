import 'package:flutter/material.dart';

import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../theme/app_spacing.dart';

/// Mail — pestañas **visuales** + hilos simulados.
class MailScreen extends StatefulWidget {
  const MailScreen({super.key});

  @override
  State<MailScreen> createState() => _MailScreenState();
}

class _MailScreenState extends State<MailScreen> {
  int _folder = 0; // 0 Principal, 1 Social, 2 Promociones

  static const _tabs = ['Principal', 'Social', 'Promociones'];

  static final List<List<(String, String, String)>> _mockMail = [
    [
      (
        'Laura M.',
        '¿Nos vemos el martes?',
        'Hola José, avísame si te viene bien…',
      ),
      ('Banco Demo', 'Resumen de tu cuenta', 'No es un correo real.'),
    ],
    [
      (
        'Equipo fútbol',
        'Partido el domingo',
        'Llevamos camisetas nuevas (mock).',
      ),
    ],
    [
      (
        'Newsletter UX',
        '5 tips de accesibilidad',
        'Promo simulada · sin enlaces.',
      ),
      ('Tienda muebles', '-20% esta semana', 'Oferta ficticia.'),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final mails = _mockMail[_folder];

    return SafeArea(
      child: Column(
        key: const Key('tab_mail'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppHeader(
            title: 'Mail',
            subtitle: 'Bandejas simuladas · sin IMAP',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SegmentedButton<int>(
              segments: [
                for (var i = 0; i < _tabs.length; i++)
                  ButtonSegment<int>(value: i, label: Text(_tabs[i])),
              ],
              selected: {_folder},
              onSelectionChanged: (s) => setState(() => _folder = s.first),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                100,
              ),
              itemCount: mails.length,
              itemBuilder: (context, i) {
                final m = mails[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: scheme.secondaryContainer,
                              child: Text(
                                m.$1.isNotEmpty ? m.$1[0] : '?',
                                style: text.labelLarge?.copyWith(
                                  color: scheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(child: Text(m.$1, style: text.titleSmall)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          m.$2,
                          style: text.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          m.$3,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
