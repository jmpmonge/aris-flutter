import '../models/note_model.dart';

abstract final class MockNotes {
  static const quickLabels = ['Compra', 'Ideas viaje', 'Libros'];

  static List<NoteModel> recent() {
    return const [
      NoteModel(
        id: 'mock_note_ideas_aris',
        title: 'Ideas para Aris',
        body: 'Roadmap UI, voz y calendario…',
      ),
      NoteModel(
        id: 'mock_note_calendar_review',
        title: 'Revisión calendario',
        body: 'Semana, avisos y huecos libres…',
      ),
      NoteModel(
        id: 'mock_note_trip',
        title: 'Lista de viaje',
        body: 'Pasaporte, reservas, equipaje…',
      ),
      NoteModel(
        id: 'mock_note_books',
        title: 'Libros 2026',
        body: 'Ficción · ensayo · cómic',
      ),
      NoteModel(
        id: 'mock_note_shop',
        title: 'Lista compras',
        body: 'Pan, leche, fruta…',
      ),
    ];
  }

  static List<NoteModel> homeHighlights() =>
      List<NoteModel>.unmodifiable(recent().take(4));
}
