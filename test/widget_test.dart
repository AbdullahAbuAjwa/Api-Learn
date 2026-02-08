// اختبار الودجت الأساسي لتطبيق API Learn
// Basic Flutter widget test for the API Learn app.

import 'package:flutter_test/flutter_test.dart';

import 'package:api_learn/main.dart';

void main() {
  testWidgets('API Learn app loads correctly', (WidgetTester tester) async {
    // بناء التطبيق | Build our app
    await tester.pumpWidget(const ApiLearnApp());

    // التحقق من تحميل الشاشة الرئيسية
    // Verify the home screen loads
    expect(find.text('API Learn'), findsOneWidget);
  });
}
