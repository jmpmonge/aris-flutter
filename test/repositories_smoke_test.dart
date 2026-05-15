import 'package:flutter_test/flutter_test.dart';

import 'package:aris_flutter_v0_22/core/api/api_client.dart';
import 'package:aris_flutter_v0_22/core/repositories/repositories.dart';

void main() {
  test('ApiClient provisional: POST devuelve fallo estable', () async {
    final client = ApiClient.provisional();
    final r = await client.post('/v1/tasks', body: {});
    expect(r.isFailure, isTrue);
    expect(r.error?.code, 'no_backend');
  });

  test('Repositories locales delegan sin lanzar (humo)', () {
    expect(Repositories.user.getGreetingForNow(), isNotEmpty);
    expect(Repositories.assistant.getQuickActions(), isNotEmpty);
    expect(Repositories.task.getTodayTasks(), isNotEmpty);
    expect(Repositories.note.getQuickLabels(), isNotEmpty);
    expect(Repositories.calendar.getTodayEvents(), isNotEmpty);
    expect(Repositories.mail.getFolderLabels(), isNotEmpty);
    expect(Repositories.settings.getThemeMode(), isNotNull);
  });
}
