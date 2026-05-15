import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aris_flutter_v0_22/app.dart';

void main() {
  testWidgets('Arranque: pantalla preview home con saludo', (WidgetTester tester) async {
    await tester.pumpWidget(const ArisApp());
    expect(find.byKey(const Key('home_preview_screen')), findsOneWidget);
    expect(find.text('Hola, José'), findsOneWidget);
    expect(find.text('Próxima cita'), findsOneWidget);
    expect(find.text('Tareas'), findsOneWidget);
    expect(find.text('Notas'), findsOneWidget);
  });
}
