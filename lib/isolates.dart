import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

import 'package:generate_crossword/model.dart' as model;
import 'package:generate_crossword/utils.dart';

/// Explores random candidate word placements in a background isolate,
/// yielding valid [model.Crossword] updates until 80% of the grid is filled.
///
/// This function lives in its own library (not in `providers.dart`) so that
/// the closure passed to `compute` only captures immutable, isolate-sendable
/// values: a [model.Crossword] and the Dart record `(word, direction,
/// location)`. Closures defined inside a Riverpod provider would capture the
/// surrounding `Ref`/provider element, which is unsendable.
Stream<model.Crossword> exploreCrosswordSolutions({
  required model.Crossword crossword,
  required BuiltSet<String> wordList,
}) async* {
  final random = Random();
  final targetFilled = (crossword.width * crossword.height * 0.8).round();

  yield crossword;

  while (crossword.characters.length < targetFilled) {
    final direction = model.Direction.values[random.nextInt(model.Direction.values.length)];
    final word = wordList.randomElement();
    final location = model.Location.at(
      random.nextInt(crossword.width),
      random.nextInt(crossword.height),
    );

    // Validate the candidate placement in a background isolate so that the
    // heavy `addWord`/`valid` work never blocks Flutter's render loop.
    final candidate = await compute(((String, model.Direction, model.Location) wordToAdd) {
      final (word, direction, location) = wordToAdd;
      return crossword.addWord(word: word, direction: direction, location: location);
    }, (word, direction, location));

    if (candidate != null) {
      crossword = candidate;
    }

    yield crossword;

    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}
