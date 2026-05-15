import 'package:flutter/material.dart';

import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../theme/app_spacing.dart';

/// Calendario — selector Día / Semana / Mes **solo visual** + eventos mock.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _view = 0; // 0 día, 1 semana, 2 mes

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    const events = [
      ('09:00', 'Café con Laura', 'Café Central (mock)'),
      ('12:30', 'Almuerzo equipo', 'Online'),
      ('18:00', 'Gimnasio', 'Plan suave'),
    ];

    return SafeArea(
      child: ListView(
        key: const Key('tab_calendar'),
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          const AppHeader(
            title: 'Calendario',
            subtitle: 'Vista simulada · sin sincronización real',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Día')),
                ButtonSegment(value: 1, label: Text('Semana')),
                ButtonSegment(value: 2, label: Text('Mes')),
              ],
              selected: {_view},
              onSelectionChanged: (s) => setState(() => _view = s.first),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              _view == 0
                  ? 'Vista día — 12 de mayo (ejemplo)'
                  : _view == 1
                      ? 'Vista semana — semana actual (ejemplo)'
                      : 'Vista mes — mayo (ejemplo)',
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...events.map(
            (e) => Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 52,
                      child: Text(e.$1, style: text.labelLarge),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.$2, style: text.titleSmall),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            e.$3,
                            style: text.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
