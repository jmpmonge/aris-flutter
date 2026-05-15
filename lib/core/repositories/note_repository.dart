import '../models/local_action_model.dart';
import '../models/note_model.dart';
import '../services/local_action_service.dart';
import '../services/note_service.dart';

/// Contrato de notas (mock + locales). Implementación: [LocalNoteRepository].
abstract interface class NoteRepository {
  List<String> getQuickLabels();

  List<NoteModel> getRecentNotes();

  List<NoteModel> getHomeHighlightNotes();

  List<LocalActionModel> getLocalNotes();

  LocalActionModel createLocalNote({
    required String title,
    required String content,
    String? category,
  });
}

final class LocalNoteRepository implements NoteRepository {
  @override
  List<String> getQuickLabels() => NoteService.getQuickLabels();

  @override
  List<NoteModel> getRecentNotes() => NoteService.getRecentNotes();

  @override
  List<NoteModel> getHomeHighlightNotes() => NoteService.getHomeHighlightNotes();

  @override
  List<LocalActionModel> getLocalNotes() {
    return LocalActionService.getActionsByType(LocalActionType.note);
  }

  @override
  LocalActionModel createLocalNote({
    required String title,
    required String content,
    String? category,
  }) {
    return LocalActionService.createNote(
      title: title,
      content: content,
      category: category,
    );
  }
}
