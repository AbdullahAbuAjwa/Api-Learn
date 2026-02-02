// This is a basic Flutter widget test for the API Learn app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:api_learn/main.dart';

void main() {
  testWidgets('API Learn app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ApiLearnApp());

    // Verify that the home screen loads with the title
    expect(find.text('API Learn'), findsOneWidget);

    // Verify that the learning sections are displayed
    expect(find.text('Start Learning APIs with Dio'), findsOneWidget);
  });
}
