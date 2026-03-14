import 'package:flutter_test/flutter_test.dart';
import 'package:guardia_app/app.dart';
import 'package:guardia_app/di/injection_container.dart' as di;

void main() {
  testWidgets('GuardiaApp renders successfully', (tester) async {
    // We need to initialize DI before pumping the widget
    await di.init();
    await tester.pumpWidget(const GuardiaApp());
    expect(find.byType(GuardiaApp), findsOneWidget);
  });
}
