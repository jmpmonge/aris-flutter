import 'package:flutter/material.dart';

import '../../../shared/widgets/app_header.dart';
import '../../../theme/app_spacing.dart';

/// Tareas — hoy y próximas, estados mock (sin persistencia).
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _today = [
    _TaskItem('Preparar reunión lunes', false),
    _TaskItem('Pagar suscripción cloud', true),
    _TaskItem('Revisar borrador de correo', false),
  ];

  final _upcoming = [
    _TaskItem('Reservar restaurante (mock)', false),
    _TaskItem('Actualizar documentación', false),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    Widget section(String title, List<_TaskItem> items) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Text(
              title,
              style: text.labelSmall?.copyWith(
                letterSpacing: 1.1,
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...List.generate(items.length, (i) {
            final t = items[i];
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Card(
                elevation: Theme.of(context).cardTheme.elevation ?? 2,
                shadowColor: Theme.of(context).cardTheme.shadowColor,
                shape: Theme.of(context).cardTheme.shape,
                clipBehavior: Clip.antiAlias,
                child: CheckboxListTile(
                  value: t.done,
                  onChanged: (_) {
                    setState(() => t.done = !t.done);
                  },
                  title: Text(
                    t.title,
                    style: text.bodyLarge?.copyWith(
                      decoration: t.done
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: t.done
                          ? scheme.onSurfaceVariant
                          : scheme.onSurface,
                    ),
                  ),
                  secondary: Icon(
                    t.done
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: t.done ? scheme.secondary : scheme.onSurfaceVariant,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                ),
              ),
            );
          }),
        ],
      );
    }

    return SafeArea(
      child: CustomScrollView(
        key: const Key('tab_tasks'),
        slivers: [
          const SliverToBoxAdapter(
            child: AppHeader(
              title: 'Tareas',
              subtitle: 'Prioridades suaves · datos de ejemplo',
            ),
          ),
          SliverToBoxAdapter(child: section('HOY', _today)),
          SliverToBoxAdapter(child: section('PRÓXIMAS', _upcoming)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _TaskItem {
  _TaskItem(this.title, this.done);

  final String title;
  bool done;
}
