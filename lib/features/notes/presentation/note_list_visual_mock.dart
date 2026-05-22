import '../../../core/models/note_model.dart';

// MOCK VISUAL TEMPORAL v0.49.43 — eliminar archivo + referencias en notes_screen al aprobar.

/// Nota de prueba con todos los metadatos de listado para validación visual.
abstract final class NoteListVisualMock {
  NoteListVisualMock._();

  /// Cambiar a `false` para ocultar el mock sin borrar el archivo.
  static const bool enabled = true;

  static const String id = '__mock_visual_v04943__';

  static bool isMock(NoteModel note) => note.id == id;

  static NoteModel get note => const NoteModel(
        id: id,
        title: 'Ideas reunión Aris',
        body:
            'Preparar agenda, revisar presupuesto, confirmar asistentes y adjuntar documentación previa.',
        pinned: true,
        listTimeLabel: '12:48',
        hasAttachments: true,
        attachmentName: 'brief_reunion.pdf',
        hasChecklist: true,
        checklistItemCount: 3,
        tags: ['aris', 'reunión', 'pendiente'],
      );
}
