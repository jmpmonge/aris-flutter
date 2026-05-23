import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../mock/mock_notes.dart';
import '../models/backend_note_mapper.dart';
import '../models/local_action_model.dart';
import '../models/note_model.dart';
import '../services/local_action_service.dart';
import '../services/note_service.dart';

abstract interface class NoteRepository {
  ValueNotifier<int> get readRevision;

  /// `true` si el último GET `/notes` tuvo éxito (lista puede estar vacía).
  bool get readsFromBackend;

  Future<bool> refreshFromBackend();

  List<String> getQuickLabels();

  List<NoteModel> getRecentNotes();

  List<NoteModel> getHomeHighlightNotes();

  List<LocalActionModel> getLocalNotes();

  LocalActionModel createLocalNote({
    required String title,
    required String content,
    String? category,
  });

  /// `PATCH /notes/{id}` con **`{"content": ...}`**. [title], si viene, va incrustado
  /// al inicio del texto enviado (el contrato HTTP actual no envía campo `title`).
  Future<bool> updateNote(
    String noteId, {
    String? title,
    String? content,
  });

  Future<bool> deleteNote(String noteId);
}

final class HybridNoteRepository implements NoteRepository {
  HybridNoteRepository(this._client);

  final ApiClient _client;

  @override
  final ValueNotifier<int> readRevision = ValueNotifier<int>(0);

  bool _readsOk = false;
  List<NoteModel> _cached = [];

  @override
  bool get readsFromBackend => _readsOk;

  void _applyNotesPayload(List<Map<String, dynamic>> rawList) {
    _cached = BackendNoteMapper.parseSortedNewest(rawList);
  }

  @override
  Future<bool> refreshFromBackend() async {
    final res = await _client.getNotes();
    if (!res.isSuccess || res.data == null) {
      _readsOk = false;
      _cached = [];
      readRevision.value++;
      return false;
    }
    _readsOk = true;
    _applyNotesPayload(res.data!);
    readRevision.value++;
    return true;
  }

  Future<void> _reloadNotesAfterMutation() async {
    if (!_readsOk) return;

    final res = await _client.getNotes();
    if (!res.isSuccess || res.data == null) {
      debugPrint(
        '[HybridNoteRepository] refresco tras mutación sin éxito, se mantiene cache previa.',
      );
      return;
    }

    _readsOk = true;
    _applyNotesPayload(res.data!);
    readRevision.value++;
  }

  /// Superpone notas demo enriquecidas sobre backend (v0.49.96).
  static List<NoteModel> _withDemoNotesOverlay(
    List<NoteModel> backend,
    List<NoteModel> demo,
  ) {
    final demoTitles =
        demo.map((n) => n.title.trim().toLowerCase()).toSet();
    final filtered = backend.where((n) {
      if (MockNotes.demoNoteIds.contains(n.id)) return false;
      return !demoTitles.contains(n.title.trim().toLowerCase());
    }).toList();
    return [...demo, ...filtered];
  }

  @override
  List<String> getQuickLabels() => NoteService.getQuickLabels();

  @override
  List<NoteModel> getRecentNotes() {
    final demo = MockNotes.recent();
    if (!_readsOk) return demo;
    return _withDemoNotesOverlay(_cached, demo);
  }

  @override
  List<NoteModel> getHomeHighlightNotes() {
    final demo = MockNotes.homeHighlights();
    if (!_readsOk) return demo;
    return _withDemoNotesOverlay(_cached, demo).take(4).toList();
  }

  @override
  List<LocalActionModel> getLocalNotes() =>
      LocalActionService.getActionsByType(LocalActionType.note);

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

  @override
  Future<bool> updateNote(String noteId, {String? title, String? content}) async {
    if (!_readsOk) return false;
    if ((title ?? '').trim().isEmpty && (content ?? '').trim().isEmpty) {
      return false;
    }

    final res = await _client.updateNote(
      noteId,
      title: title,
      content: content,
    );
    if (!res.isSuccess) return false;

    await _reloadNotesAfterMutation();
    return true;
  }

  @override
  Future<bool> deleteNote(String noteId) async {
    if (!_readsOk) return false;

    final res = await _client.deleteNote(noteId);
    if (!res.isSuccess) return false;

    await _reloadNotesAfterMutation();
    return true;
  }
}
