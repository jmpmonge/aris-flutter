import '../models/note_model.dart';

abstract final class MockNotes {
  static const quickLabels = ['Compra', 'Ideas viaje', 'Libros'];

  /// IDs demo siempre visibles aunque haya backend (v0.49.96).
  static const demoNoteIds = {
    'mock_note_ideas_aris',
    'mock_note_calendar_review',
    'mock_note_trip',
    'mock_note_books',
    'mock_note_shop',
  };

  static List<NoteModel> recent() {
    return const [
      NoteModel(
        id: 'mock_note_ideas_aris',
        title: 'Ideas para Aris',
        body:
            'Roadmap UI:\n'
            '• Home compacto con HOY, Tareas y Notas\n'
            '• Voz Aris en input inferior\n'
            '• Calendario Día con tarjeta expandida\n\n'
            'Prioridad: pulido visual antes de conectar más backend.',
        listTimeLabel: 'Hoy, 09:15',
        tags: ['aris', 'roadmap'],
        pinned: true,
      ),
      NoteModel(
        id: 'mock_note_calendar_review',
        title: 'Revisión calendario',
        body:
            'Comprobar en vista Día:\n'
            '• Tarjeta expandida con ubicación, aviso y notas\n'
            '• Hueco libre entre eventos\n'
            '• Modo claro y oscuro',
        listTimeLabel: 'Ayer, 18:40',
        tags: ['calendario'],
        folderName: 'Producto',
      ),
      NoteModel(
        id: 'mock_note_trip',
        title: 'Lista de viaje',
        body:
            'Documentación:\n'
            '• Pasaporte\n'
            '• Tarjeta embarque\n\n'
            'Equipaje de mano: cargador, auriculares, libro.',
        listTimeLabel: 'Lun, 11:20',
        tags: ['viaje'],
        hasChecklist: true,
        checklistItemCount: 5,
      ),
      NoteModel(
        id: 'mock_note_books',
        title: 'Libros 2026',
        body:
            'Ficción: Project Hail Mary\n'
            'Ensayo: Pensar rápido, pensar despacio\n'
            'Cómic: Saga vol. 1',
        listTimeLabel: 'Mar, 08:05',
        tags: ['libros', 'lectura'],
      ),
      NoteModel(
        id: 'mock_note_shop',
        title: 'Lista compras',
        body: 'Pan integral, leche, fruta de temporada, aceite de oliva, café molido.',
        listTimeLabel: 'Hoy, 07:30',
        tags: ['compra'],
        hasAttachments: true,
        attachmentName: 'lista_mercado.pdf',
      ),
    ];
  }

  static List<NoteModel> homeHighlights() =>
      List<NoteModel>.unmodifiable(recent().take(4));
}
