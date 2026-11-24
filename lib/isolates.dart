import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:characters/characters.dart';
import 'package:flutter/foundation.dart';

import 'package:generate_crossword/model.dart' as model;
import 'package:generate_crossword/utils.dart';

/// Drives crossword generation as a guided backtracking search over a
/// [model.WorkQueue], yielding crossword updates until the queue is
/// completed (no open intersections remain).
///
/// This function lives in its own library (not in `providers.dart`) so that
/// the top-level `_generateCandidate` passed to `compute` only captures
/// immutable, isolate-sendable values: a [model.Crossword], a
/// `BuiltSet<String>`, a [model.Location] and a [model.Direction]. Closures
/// defined inside a Riverpod provider would capture the surrounding
/// `Ref`/provider element, which is unsendable.
Stream<model.WorkQueue> exploreCrosswordSolutions({
  required model.Crossword crossword,
  required BuiltSet<String> wordList,
}) async* {
  final stopwatch = Stopwatch()..start();
  final random = Random();

  var workQueue = model.WorkQueue.from(
    crossword: crossword,
    candidateWords: wordList,
    startLocation: model.Location.at(0, 0),
  );

  yield workQueue;

  while (!workQueue.isCompleted) {
    final locations = workQueue.locationsToTry.keys.toList();
    final location = locations[random.nextInt(locations.length)];
    final direction = workQueue.locationsToTry[location]!;

    final candidate = await compute(
      _generateCandidate,
      (workQueue.crossword, workQueue.candidateWords, location, direction),
    );

    workQueue = candidate != null
        ? workQueue.updateFrom(candidate)
        : workQueue.remove(location);

    yield workQueue;
  }

  stopwatch.stop();
  debugPrint('Total generation time: ${stopwatch.elapsed.formatted}');
}

/// Tries up to 1,000 shuffled candidate words containing the character at
/// [model.Location] for the given [model.Direction], returning the first
/// crossword that accepts one, or `null` when the location is a dead end.
///
/// Each word is tried aligned so that any of its occurrences of the
/// intersection character lands on the target location, not just its first
/// letter, which lets words cross at any position.
model.Crossword? _generateCandidate(
  (model.Crossword, BuiltSet<String>, model.Location, model.Direction) args,
) {
  final (crossword, candidateWords, location, direction) = args;

  // An empty grid has no character at the seed location yet; any word is a
  // valid seed. Otherwise only words containing the intersection character
  // can cross there.
  final character = crossword.characters[location]?.character;
  final candidates = character == null
      ? candidateWords
      : candidateWords.where((word) => word.contains(character));

  final shuffledWords = candidates.toList()..shuffle(Random());

  for (final word in shuffledWords.take(1000)) {
    for (final (idx, wordCharacter) in word.characters.indexed) {
      // The seed word must start exactly at the seed location.
      if (character == null && idx != 0) continue;
      if (character != null && wordCharacter != character) continue;

      final start = switch (direction) {
        model.Direction.across => location.leftOffset(idx),
        model.Direction.down => location.upOffset(idx),
      };

      final candidate = crossword.addWord(
        word: word,
        direction: direction,
        location: start,
      );
      if (candidate != null) return candidate;
    }
  }

  return null;
}
