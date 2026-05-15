import '../mock/mock_notes.dart';
import '../models/note_model.dart';

abstract final class NoteService {
  static List<String> getQuickLabels() => MockNotes.quickLabels;

  static List<NoteModel> getRecentNotes() => MockNotes.recent();

  static List<NoteModel> getHomeHighlightNotes() => MockNotes.homeHighlights();
}
