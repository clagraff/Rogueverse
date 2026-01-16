// Basic Flutter widget test for Rogueverse.

import 'package:flutter_test/flutter_test.dart';
import 'package:rogueverse/app/application.dart';

void main() {
  testWidgets('Main menu displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const Application());

    // Verify that main menu elements are present.
    expect(find.text('Rogueverse'), findsOneWidget);
    expect(find.text('New Game'), findsOneWidget);
    expect(find.text('Load Game'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Quit'), findsOneWidget);
  });
}
