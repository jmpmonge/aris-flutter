import 'assistant_repository.dart';
import 'calendar_repository.dart';
import 'mail_repository.dart';
import 'note_repository.dart';
import 'settings_repository.dart';
import 'task_repository.dart';
import 'user_repository.dart';

/// Registro provisional de repositorios **locales** (v0.37).
///
/// Cuando exista API: sustituir implementaciones o inyectar clientes desde
/// `main`/DI sin que las pantallas conozcan `ApiClient` directamente.
abstract final class Repositories {
  static final AssistantRepository assistant = LocalAssistantRepository();

  static final TaskRepository task = LocalTaskRepository();
  static final NoteRepository note = LocalNoteRepository();
  static final CalendarRepository calendar = LocalCalendarRepository();
  static final MailRepository mail = LocalMailRepository();
  static final UserRepository user = LocalUserRepository();
  static final SettingsRepository settings = LocalSettingsRepository();
}
