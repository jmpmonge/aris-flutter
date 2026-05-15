import 'package:flutter_test/flutter_test.dart';

import 'package:aris_flutter_v0_22/app.dart';

void main() {
  testWidgets('Arranque: muestra título base Aris', (WidgetTester tester) async {
    await tester.pumpWidget(const ArisApp());
    expect(find.text('Aris · base'), findsOneWidget);
  });
}
