import 'package:flutter/material.dart';

/// Mapeo estable de claves a iconos Material (evita acoplar modelos a Flutter donde no toque).
IconData iconFromKey(String key) {
  return switch (key) {
    'person_rounded' => Icons.person_rounded,
    'tune_rounded' => Icons.tune_rounded,
    'hub_outlined' => Icons.hub_outlined,
    'shield_outlined' => Icons.shield_outlined,
    'help_outline_rounded' => Icons.help_outline_rounded,
    'mic_rounded' => Icons.mic_rounded,
    'add_task_rounded' => Icons.add_task_rounded,
    'event_available_rounded' => Icons.event_available_rounded,
    'note_add_rounded' => Icons.note_add_rounded,
    'mark_email_read_outlined' => Icons.mark_email_read_outlined,
    'mail_outline_rounded' => Icons.mail_outline_rounded,
    _ => Icons.smart_button_outlined,
  };
}
