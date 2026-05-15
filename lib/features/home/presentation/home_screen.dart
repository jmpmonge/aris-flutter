import 'package:flutter/material.dart';

import '../../../shared/widgets/home_brand_header.dart';
import '../../../shared/widgets/home_greeting_card.dart';
import '../../../shared/widgets/recent_conversation_card.dart';
import '../../../shared/widgets/suggestion_card.dart';
import '../../../shared/widgets/today_summary_card.dart';
import '../../../theme/app_spacing.dart';

/// Inicio — estructura vertical según prototipo funcional + estética premium Aris.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static String _greetingForNow() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días, José';
    if (h < 20) return 'Buenas tardes, José';
    return 'Buenas noches, José';
  }

  @override
  Widget build(BuildContext context) {
    const events = [
      '15:30 · Revisión médica anual (Centro Norte, mock)',
      '18:00 · Recoger paquete en locker',
    ];
    const tasks = [
      'Responder al equipo de diseño',
      'Llamar a papá antes de cenar',
      'Enviar borrador del informe',
    ];
    const notes = [
      'Idea: playlist “concentración suave”',
      'Nota: regalo cumple Ana (libro)',
    ];

    /// Espacio extra: la barra de chat y la nav los añade el shell.
    const bottomInset = 168.0;

    return SafeArea(
      bottom: false,
      child: ListView(
        key: const Key('tab_home'),
        padding: const EdgeInsets.only(bottom: bottomInset),
        children: [
          const HomeBrandHeader(),
          const SizedBox(height: AppSpacing.sm),
          HomeGreetingCard(
            greeting: _greetingForNow(),
            summary:
                'Tienes 12 tareas pendientes y 2 eventos esta tarde. Respira: es un resumen simulado para diseño.',
          ),
          const SizedBox(height: AppSpacing.md),
          const SuggestionCard(
            message: 'Revisa tus tareas pendientes antes del fin de semana.',
          ),
          const SizedBox(height: AppSpacing.lg),
          const TodaySummaryCard(
            events: events,
            tasks: tasks,
            notes: notes,
          ),
          const SizedBox(height: AppSpacing.lg),
          const RecentConversationCard(),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
