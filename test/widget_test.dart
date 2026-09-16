// Basic smoke test for the donut carousel screen.
//
// Note: the carousel drives a repeating autoplay Timer and a continuously
// spinning logo AnimationController, so this deliberately avoids
// `pumpAndSettle` (which pumps until no frame is scheduled and would hang
// forever against a repeating animation) in favor of bounded `pump()` calls.

import 'package:donut_spinning_app/root.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Donut carousel opens on the first flavor', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('dodonut'), findsOneWidget);
    expect(find.text('Strawberry Bliss'), findsOneWidget);
  });
}
