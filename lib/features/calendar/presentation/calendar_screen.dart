import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/repositories/repositories.dart';
import 'calendar_body_views.dart';
import 'calendar_event_sheet.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/home_aris_reply_card.dart';
import '../../../shared/widgets/local_action_form_sheet.dart';
import '../../../theme/app_spacing.dart';

/// Calendario — input fijo de Aris al pie como Home (v0.49.5).
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _view = 0;
  bool _arisSending = false;

  @override
  void initState() {
    super.initState();
    unawaited(Repositories.calendar.refreshFromBackend());
    Repositories.calendar.readRevision.addListener(_onCalendarReads);
  }

  @override
  void dispose() {
    Repositories.calendar.readRevision.removeListener(_onCalendarReads);
    super.dispose();
  }

  void _onCalendarReads() => setState(() {});

  double _listBottomPadding(BuildContext context) {
    return HomeArisFixedInputBar.dockHeight +
        AppSpacing.homeScrollBottomBreathing;
  }

  Future<void> _sendArisMessage(String text) async {
    final t = text.trim();
    if (t.isEmpty) return;

    setState(() => _arisSending = true);
    await Repositories.assistant.sendMessage(t);
    if (!mounted) return;
    setState(() => _arisSending = false);
  }

  void _onMicPressed() {
    Repositories.assistant.sendVoicePendingNotice();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final calendarBody = switch (_view) {
      0 => CalendarDayView(
          events: Repositories.calendar.getTodayEvents(),
        ),
      1 => CalendarWeekView(
          weekStart: mondayOfWeek(DateTime.now()),
          calendarRepository: Repositories.calendar,
        ),
      _ => CalendarMonthView(calendarRepository: Repositories.calendar),
    };

    return SafeArea(
      top: true,
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              key: const Key('tab_calendar'),
              padding: EdgeInsets.only(bottom: _listBottomPadding(context)),
              children: [
                AppHeader(
                  title: 'Calendario',
                  subtitle: _view == 1
                      ? null
                      : 'Servidor PATCH/DELETE cuando GET /events OK · datos locales como respaldo',
                  trailing: IconButton.filledTonal(
                    onPressed: () =>
                        LocalActionFormSheet.showEventForm(context),
                    icon: const Icon(Icons.add_rounded),
                    tooltip: 'Nuevo evento',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
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
                if (_view != 1) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      switch (_view) {
                        0 => 'Vista día · franjas horarias mock',
                        _ => 'Vista mes · cuadrícula y día seleccionado mock',
                      },
                      style: text.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                calendarBody,
                if (Repositories.calendar.readsFromBackend &&
                    Repositories.calendar.allBackendEvents.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      'Todos los eventos del servidor',
                      style: text.labelSmall?.copyWith(
                        letterSpacing: 0.8,
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...Repositories.calendar.allBackendEvents.map((e) {
                    final dateLabel = e.dateIso?.isNotEmpty == true
                        ? e.dateIso!
                        : e.visibleDateLabel.isNotEmpty
                        ? e.visibleDateLabel
                        : '—';
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      child: AppCard(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.title,
                                    style: text.titleSmall,
                                  ),
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    '$dateLabel · ${e.timeHm}',
                                    style: text.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  if (e.detail.isNotEmpty)
                                    Text(
                                      e.detail,
                                      style: text.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (calendarShouldShowBackendActions(e))
                              calendarBackendEventOverflowMenu(context, e),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
          HomeArisFixedInputBar(
            hintText: 'Añade un evento con Aris…',
            isSending: _arisSending,
            onSubmit: _sendArisMessage,
            onMicPressed: _onMicPressed,
          ),
        ],
      ),
    );
  }
}
