import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nook/main.dart';

void main() {
  testWidgets('NooK app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NooKApp());
    await tester.pump();

    expect(find.text('NooK'), findsAtLeast(1));
  });
}
