import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aris_flutter_v0_22/app.dart';

void main() {
  testWidgets('Shell: inicio muestra saludo y pestañas navegables', (WidgetTester tester) async {
    await tester.pumpWidget(const ArisApp());

    expect(find.text('Hola, José'), findsOneWidget);
    expect(find.text('Calendario'), findsWidgets);
    expect(find.byKey(const Key('tab_home')), findsOneWidget);

    await tester.tap(find.text('Calendario'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tab_calendar')), findsOneWidget);

    await tester.tap(find.text('Notas'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tab_notes')), findsOneWidget);

    await tester.tap(find.text('Mail'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tab_mail')), findsOneWidget);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tab_profile')), findsOneWidget);
  });
}
