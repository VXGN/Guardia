import 'package:flutter_test/flutter_test.dart';

import 'package:guardia_app/app.dart';

void main() {
  testWidgets('GuardiaApp renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const GuardiaApp());

    // Verify that the app title is displayed
    expect(find.text('Guardia'), findsWidgets);
    expect(find.text('Foundation Ready'), findsOneWidget);
  });
}
