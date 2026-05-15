import 'package:flutter/material.dart';

/// Acciones rápidas mock para [AssistantScreen].
abstract final class AssistantMockContent {
  static const actions = <(IconData, String, String)>[
    (Icons.mic_rounded, 'Hablar con Aris', 'Dictado simulado · sin grabación'),
    (Icons.add_task_rounded, 'Crear tarea', 'Añadir a la lista mock'),
    (Icons.event_available_rounded, 'Crear evento', 'Sin calendario real'),
    (Icons.note_add_rounded, 'Crear nota', 'Borrador local ficticio'),
    (Icons.mark_email_read_outlined, 'Resumir correo', 'Sin buzón conectado'),
  ];
}
