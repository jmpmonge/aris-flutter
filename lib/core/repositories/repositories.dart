import 'dart:async';

import '../api/api_client.dart';
import '../services/backend_reads_caption.dart';
import 'assistant_repository.dart';
import 'backend_status_repository.dart';
import 'calendar_repository.dart';
import 'history_repository.dart';
import 'mail_repository.dart';
import 'note_repository.dart';
import 'settings_repository.dart';
import 'task_repository.dart';
import 'user_repository.dart';

/// Registro único del cliente contra `ApiConfig`.
abstract final class Repositories {
  static final ApiClient backendClient = ApiClient.localBackend();

  static final HistoryRepository history =
      HybridHistoryRepository(backendClient);

  /// Solo `GET /health`.
  static final BackendStatusRepository backendStatus =
      RemoteBackendStatusRepository(backendClient);

  static final TaskRepository task = HybridTaskRepository(backendClient);
  static final NoteRepository note = HybridNoteRepository(backendClient);
  static final CalendarRepository calendar =
      HybridCalendarRepository(backendClient);

  static final MailRepository mail = LocalMailRepository();
  static final UserRepository user = LocalUserRepository();

  static final SettingsRepository settings = LocalSettingsRepository();

  /// Cuatro GET v0.41: `/history`, `/tasks`, `/notes`, `/events`.
  ///
  /// Tras cualquier respuesta útil de `POST /message` (v0.44.1) se vuelve a
  /// invocar también para refrescar vista sin esperar cambio de pestaña.
  static Future<void> prefetchBackendReads() async {
    final results = await Future.wait<bool>([
      history.refreshFromBackend(),
      task.refreshFromBackend(),
      note.refreshFromBackend(),
      calendar.refreshFromBackend(),
    ]);

    final ok = results.where((v) => v).length;

    if (ok == results.length && results.length == 4) {
      backendReadsCaption.value = 'Datos del backend';
    } else if (ok == 0) {
      backendReadsCaption.value = 'Backend sin conexión · modo local';
    } else {
      backendReadsCaption.value = 'Parcialmente en local ($ok/4 lecturas)';
    }
  }

  static final AssistantRepository assistant = DefaultAssistantRepository(
    backendClient,
    afterSuccessfulPost: prefetchBackendReads,
  );
}
