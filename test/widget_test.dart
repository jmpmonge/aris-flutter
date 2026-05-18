import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aris_flutter_v0_22/app.dart';

void main() {
  testWidgets('Shell: saludo dinámico, asistente desde Inicio y pestañas', (WidgetTester tester) async {
    await tester.pumpWidget(const ArisApp());

    expect(find.textContaining('José'), findsWidgets);
    expect(find.text('aris'), findsWidgets);
    expect(find.byKey(const Key('tab_home')), findsOneWidget);

    await tester.tap(find.byTooltip('Hablar con Aris'));
    await tester.pumpAndSettle();
    expect(find.text('Acciones rápidas'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tab_home')), findsOneWidget);

    await tester.tap(find.text('Calendario'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tab_calendar')), findsOneWidget);

    await tester.tap(find.text('Notas'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tab_notes')), findsOneWidget);

    await tester.tap(find.text('Tareas'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tab_tasks')), findsOneWidget);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tab_profile')), findsOneWidget);
  });
}
