import 'package:flutter_test/flutter_test.dart';
import 'package:guardia_app/app.dart';

void main() {
  testWidgets('GuardiaApp renders successfully', (tester) async {
    await tester.pumpWidget(const GuardiaApp());
    await tester.pumpAndSettle();

    // Verify that the splash page is displayed
    expect(find.text('Guardia'), findsOneWidget);
    expect(find.text('Your Personal Safety Companion'), findsOneWidget);
  });
}
