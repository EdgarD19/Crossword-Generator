import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:generate_crossword/providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('wordList loads, normalizes and filters the SOWPODS dictionary', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final words = await container.read(wordListProvider.future);

    // SOWPODS has 267,750 entries; words of 2 letters or fewer, uppercase
    // entries and anything outside [a-z] are filtered out.
    expect(words.length, 267627);

    // Words are lowercase [a-z] and longer than 2 characters.
    for (final word in words.take(100)) {
      expect(RegExp(r'^[a-z]{3,}$').hasMatch(word), isTrue, reason: word);
    }

    // The two-letter words were removed.
    expect(words.contains('aa'), isFalse);
    expect(words.contains('aah'), isTrue);
  });
}
