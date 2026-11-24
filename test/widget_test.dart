// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import 'package:generate_crossword/main.dart';

void main() {
  testWidgets('App shows the crossword generator screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CrosswordBuilderApp());

    // Loading assets/words.txt is real asynchronous I/O; runAsync lets it
    // complete outside the fake-async clock, then pump to rebuild the UI.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();

    expect(find.text('Crossword Generator'), findsOneWidget);
    // The body is now a 2D crossword grid instead of the word list.
    expect(find.byType(TableView), findsOneWidget);

    // Unmount the app so the autoDispose crossword stream provider is
    // cancelled, and let the pending 100ms generator timer fire to avoid a
    // "Timer is still pending" invariant failure at the end of the test.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 200));
  });
}
