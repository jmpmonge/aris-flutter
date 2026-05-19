import 'package:flutter/material.dart';

import '../../../core/models/event_model.dart';
import '../../../core/repositories/repositories.dart';
import '../../../theme/app_spacing.dart';

const _kEvtUpdateFail =
    'No he podido actualizar el evento. Revisa la conexión con el backend.';
const _kEvtDeleteFail =
    'No he podido eliminar el evento. Revisa la conexión con el backend.';

/// Separa `"Luis, Ana"` → lista limpia.
List<String> parseParticipantsCsv(String raw) {
  return raw
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

void _calendarSnack(
  BuildContext context, {
  required String message,
  bool error = false,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger.clearSnackBars();
  final scheme = Theme.of(context).colorScheme;
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor:
          error ? scheme.error : scheme.surfaceContainerHighest,
      content: Text(
        message,
        style: TextStyle(
          color: error ? scheme.onError : scheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}

/// Diálogo sencillo: edición PATCH `/events/{id}`.
Future<void> showCalendarBackendEventEditor(
  BuildContext context,
  EventModel event,
) async {
  if (!Repositories.calendar.readsFromBackend ||
      !event.supportsBackendMutation) {
    _calendarSnack(context, message: _kEvtUpdateFail, error: true);
    return;
  }

  final titleCtrl = TextEditingController(text: event.title);
  final dateTxt = TextEditingController(text: event.dateText);
  final timeTxt = TextEditingController(text: event.timeText);
  final locationCtrl = TextEditingController(text: event.location);
  final descCtrl = TextEditingController(
    text: event.description.isNotEmpty ? event.description : '',
  );
  final partCtrl =
      TextEditingController(text: event.participantsCommaSeparated);

  void disposeCtrls() {
    titleCtrl.dispose();
    dateTxt.dispose();
    timeTxt.dispose();
    locationCtrl.dispose();
    descCtrl.dispose();
    partCtrl.dispose();
  }

  final scheme = Theme.of(context).colorScheme;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Editar evento'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: scheme.outline),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: dateTxt,
                decoration: InputDecoration(
                  labelText: 'Fecha (date_text)',
                  hintText: 'p. ej. mañana, 2025-05-20',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: scheme.outline),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: timeTxt,
                decoration: InputDecoration(
                  labelText: 'Hora (time_text)',
                  hintText: 'p. ej. 09:30',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: scheme.outline),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: locationCtrl,
                decoration: InputDecoration(
                  labelText: 'Ubicación',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: scheme.outline),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: descCtrl,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: scheme.outline),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: partCtrl,
                decoration: InputDecoration(
                  labelText: 'Participantes (coma)',
                  hintText: 'Luis, Ana',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: scheme.outline),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Guardar'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) {
    disposeCtrls();
    return;
  }

  final tTrim = titleCtrl.text.trim();
  final dDate = dateTxt.text.trim();
  final dTime = timeTxt.text.trim();
  final dLoc = locationCtrl.text.trim();
  final dDesc = descCtrl.text.trim();
  final plist = parseParticipantsCsv(partCtrl.text);

  disposeCtrls();

  if (!context.mounted) return;

  if (tTrim.isEmpty) {
    _calendarSnack(context, message: _kEvtUpdateFail, error: true);
    return;
  }

  final repoOk = await Repositories.calendar.updateEvent(
    event.id,
    title: tTrim,
    dateText: dDate.isNotEmpty ? dDate : null,
    timeText: dTime.isNotEmpty ? dTime : null,
    location: dLoc.isNotEmpty ? dLoc : null,
    description: dDesc.isNotEmpty ? dDesc : null,
    participants: plist.isNotEmpty ? plist : null,
  );

  if (!context.mounted) return;
  if (repoOk) {
    _calendarSnack(context, message: 'Evento actualizado.');
  } else {
    _calendarSnack(context, message: _kEvtUpdateFail, error: true);
  }
}

Future<void> confirmDeleteCalendarBackendEvent(
  BuildContext context,
  EventModel event,
) async {
  if (!Repositories.calendar.readsFromBackend ||
      !event.supportsBackendMutation) {
    _calendarSnack(context, message: _kEvtDeleteFail, error: true);
    return;
  }

  final scheme = Theme.of(context).colorScheme;
  final yes = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Eliminar evento'),
      content: Text('¿Eliminar «${event.title}» del servidor?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );

  if (yes != true || !context.mounted) return;

  final repoOk = await Repositories.calendar.deleteEvent(event.id);
  if (!context.mounted) return;
  if (repoOk) {
    _calendarSnack(context, message: 'Evento eliminado.');
  } else {
    _calendarSnack(context, message: _kEvtDeleteFail, error: true);
  }
}

/// Menú **`⋮`** para eventos servidor (vista Día/Mes/semana táctil).
Widget calendarBackendEventOverflowMenu(BuildContext context, EventModel e) {
  return PopupMenuButton<String>(
    tooltip: 'Más opciones',
    onSelected: (v) async {
      switch (v) {
        case 'edit':
          await showCalendarBackendEventEditor(context, e);
        case 'delete':
          await confirmDeleteCalendarBackendEvent(context, e);
        default:
          break;
      }
    },
    itemBuilder: (_) => const [
      PopupMenuItem(value: 'edit', child: Text('Editar')),
      PopupMenuItem(value: 'delete', child: Text('Eliminar')),
    ],
  );
}

bool calendarShouldShowBackendActions(EventModel e) {
  return Repositories.calendar.readsFromBackend &&
      e.supportsBackendMutation;
}
