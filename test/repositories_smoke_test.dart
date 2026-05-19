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

  test('ApiClient provisional: checkHealth sin URL base', () async {
    final client = ApiClient.provisional();
    final r = await client.checkHealth();
    expect(r.isFailure, isTrue);
    expect(r.error?.code, 'no_backend');
  });

  test('ApiClient provisional: sendMessage sin base', () async {
    final client = ApiClient.provisional();
    final r = await client.sendMessage('hola');
    expect(r.isFailure, isTrue);
    expect(r.error?.code, 'no_backend');
  });

  test('AssistantRepository.sendMessage rechaza texto vacío', () async {
    final r = await Repositories.assistant.sendMessage('   ');
    expect(r.isFailure, isTrue);
    expect(r.error?.code, 'empty_message');
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
