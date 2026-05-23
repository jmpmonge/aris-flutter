import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/repositories/repositories.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/home_aris_reply_card.dart';
import '../../../shared/widgets/local_action_form_sheet.dart';
import '../../../theme/aris_list_palette.dart';
import '../../../theme/app_spacing.dart';
import 'calendar_body_views.dart';

/// Calendario — vistas Día/Semana/Mes refinadas (v0.49.45).
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
    final base = HomeArisFixedInputBar.dockHeight +
        AppSpacing.homeScrollBottomBreathing;
    if (_view == 0) return base + AppSpacing.lg;
    return base;
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
    final repo = Repositories.calendar;

    final calendarBody = switch (_view) {
      0 => CalendarDayView(calendarRepository: repo),
      1 => CalendarWeekView(calendarRepository: repo),
      _ => CalendarMonthView(calendarRepository: repo),
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
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: WidgetStateProperty.resolveWith((s) {
                        if (s.contains(WidgetState.selected)) {
                          return context.arisList.canvas;
                        }
                        return context.arisList.textSecondary;
                      }),
                      backgroundColor: WidgetStateProperty.resolveWith((s) {
                        if (s.contains(WidgetState.selected)) {
                          return context.arisList.accent;
                        }
                        return context.arisList.elevated;
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                calendarBody,
                if (repo.readsFromBackend)
                  CalendarTextualBackendEventsPanel(repository: repo),
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
