// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:generate_crossword/main.dart';

void main() {
  testWidgets('App shows the crossword generator screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CrosswordBuilderApp());

    // Loading assets/words.txt is real asynchronous I/O; runAsync lets it
    // complete outside the fake-async clock, then pump to rebuild the UI.
    final loaded = await tester.runAsync(() async {
      for (var i = 0; i < 100; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return true;
      }
      return false;
    });
    expect(loaded, isTrue);
    await tester.pump();

    expect(find.text('Crossword Generator'), findsOneWidget);
    expect(find.byType(ListTile, skipOffstage: false), findsWidgets);
  });
}
