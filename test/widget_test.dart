import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('App navigation smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our login screen has a login button.
    expect(find.text('Login'), findsOneWidget);

    // Tap the 'Login' button and trigger a frame.
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify that we navigated to the main menu (shows 'Play' button).
    expect(find.text('Play'), findsOneWidget);
  });
}
