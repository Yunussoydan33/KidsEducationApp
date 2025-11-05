// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kids_learning_platform/main.dart';

void main() {
  testWidgets('Kids Learning App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KidsLearningApp());

    // Verify that our app starts with the home screen.
    expect(find.text('🌟 Çocuklar İçin Eğitim Platformu 🌟'), findsOneWidget);
    expect(find.text('Öğren, Oyna, Eğlen!'), findsOneWidget);
  });
}
