import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aris_flutter_v0_22/app.dart';

void main() {
  testWidgets('Arranque: vista previa del design system', (WidgetTester tester) async {
    await tester.pumpWidget(const ArisApp());
    expect(find.byKey(const Key('design_system_preview')), findsOneWidget);
    expect(find.text('Aris'), findsWidgets);
    expect(find.text('Explorar'), findsOneWidget);
  });
}
