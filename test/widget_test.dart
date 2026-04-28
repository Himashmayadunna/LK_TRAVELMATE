// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:lk_travelmate/main.dart';

void main() {
  testWidgets('shows the start screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(
      find.text('Find the best of Sri Lanka for every journey'),
      findsOneWidget,
    );
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsNothing);
    expect(find.text('Create Account'), findsNothing);
    expect(find.text('Sign In'), findsNothing);
  });

  testWidgets('get started opens auth choice page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final getStarted = find.text('Get Started');
    await tester.ensureVisible(getStarted);
    await tester.tap(getStarted);
    await tester.pumpAndSettle();

    expect(find.text('Welcome to LK TravelMate'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Explore as Guest'), findsOneWidget);
  });
}
