import '../models/assistant_action_model.dart';

abstract final class MockAssistantActions {
  static const list = [
    AssistantActionModel(
      id: 'mock_act_voice',
      iconKey: 'mic_rounded',
      title: 'Hablar con Aris',
      subtitle: 'Dictado simulado · sin grabación',
    ),
    AssistantActionModel(
      id: 'mock_act_task',
      iconKey: 'add_task_rounded',
      title: 'Crear tarea',
      subtitle: 'Añadir a la lista mock',
    ),
    AssistantActionModel(
      id: 'mock_act_event',
      iconKey: 'event_available_rounded',
      title: 'Crear evento',
      subtitle: 'Sin calendario real',
    ),
    AssistantActionModel(
      id: 'mock_act_note',
      iconKey: 'note_add_rounded',
      title: 'Crear nota',
      subtitle: 'Borrador local ficticio',
    ),
    AssistantActionModel(
      id: 'mock_act_mail',
      iconKey: 'mark_email_read_outlined',
      title: 'Resumir correo',
      subtitle: 'Sin buzón conectado',
    ),
  ];
}
