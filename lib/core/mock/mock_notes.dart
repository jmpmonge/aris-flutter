import '../models/note_model.dart';

abstract final class MockNotes {
  static const quickLabels = ['Compra', 'Ideas viaje', 'Libros'];

  static List<NoteModel> recent() {
    return const [
      NoteModel(
        id: 'mock_note_ideas',
        title: 'Ideas reunión',
        body: 'Bullet: timing, presupuesto, follow-up…',
      ),
      NoteModel(
        id: 'mock_note_books',
        title: 'Libros 2026',
        body: 'Ficción · ensayo · cómic (lista simulada)',
      ),
      NoteModel(
        id: 'mock_note_shop',
        title: 'Lista compras',
        body: 'Pan, leche, fruta…',
      ),
    ];
  }

  static List<NoteModel> homeHighlights() {
    return const [
      NoteModel(
        id: 'mock_home_note_playlist',
        title: 'Idea: playlist “concentración suave”',
        body: '',
      ),
      NoteModel(
        id: 'mock_home_note_gift',
        title: 'Nota: regalo cumple Ana (libro)',
        body: '',
      ),
    ];
  }
}
