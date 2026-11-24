import 'dart:async';
import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:characters/characters.dart';
import 'package:flutter/foundation.dart';

import 'package:generate_crossword/model.dart' as model;
import 'package:generate_crossword/utils.dart';

/// Drives crossword generation as a guided backtracking search over a
/// [model.WorkQueue], yielding queue updates until no open intersections
/// remain.
///
/// Each iteration dispatches a batch of up to [maxWorkerCount] parallel
/// candidate searches across worker isolates.
///
/// This function lives in its own library (not in `providers.dart`) so that
/// the top-level functions passed to `compute` only capture immutable,
/// isolate-sendable values. Closures defined inside a Riverpod provider
/// would capture the surrounding `Ref`/provider element, which is
/// unsendable.
Stream<model.WorkQueue> exploreCrosswordSolutions({
  required model.Crossword crossword,
  required BuiltSet<String> wordList,
  required int maxWorkerCount,
}) async* {
  final stopwatch = Stopwatch()..start();

  var workQueue = model.WorkQueue.from(
    crossword: crossword,
    candidateWords: wordList,
    startLocation: model.Location.at(0, 0),
  );

  yield workQueue;

  while (!workQueue.isCompleted) {
    workQueue = await compute(_generate, (workQueue, maxWorkerCount));

    yield workQueue;
  }

  stopwatch.stop();
  debugPrint('Total generation time: ${stopwatch.elapsed.formatted}');
}

/// Searches up to [maxWorkerCount] locations in parallel worker isolates,
/// applies the valid words found and removes the failed locations from the
/// queue.
///
/// All functions passed to `compute` are top-level, so they never capture
/// unsendable state. Dart records adapt several parameters cleanly onto the
/// single message of a `compute` call.
Future<model.WorkQueue> _generate((model.WorkQueue, int) args) async {
  final (workQueue, maxWorkerCount) = args;
  final random = Random();

  final locations = workQueue.locationsToTry.keys.toList()..shuffle(random);

  final candidateGeneratorFutures =
      <Future<(model.Location, model.Direction, String?)>>[];
  for (final location in locations.take(maxWorkerCount)) {
    final direction = workQueue.locationsToTry[location]!;

    candidateGeneratorFutures.add(
      compute(_generateCandidate, (
        workQueue.crossword,
        workQueue.candidateWords,
        location,
        direction,
      )),
    );
  }

  final results = await candidateGeneratorFutures.wait;

  var updated = workQueue;
  for (final (index, result) in results.indexed) {
    final (placedLocation, direction, word) = result;
    final targetLocation = locations[index];

    // Re-apply each placement against the crossword as it evolves, so
    // parallel candidates that collide with earlier ones are rejected.
    final candidate = word == null
        ? null
        : updated.crossword.addWord(
            word: word,
            direction: direction,
            location: placedLocation,
          );

    updated = candidate != null
        ? updated.updateFrom(candidate)
        : updated.remove(targetLocation);
  }

  return updated;
}

/// Searches for a word to place through the target location in the given
/// [model.Direction], stopping after 1,000 tries or 10 seconds, and returns
/// the record `(placedLocation, direction, word)` — with a `null` word when
/// the location is a dead end.
///
/// Each word is tried aligned so that any of its occurrences of the
/// intersection character lands on the target location, not just its first
/// letter, which lets words cross at any position.
(model.Location, model.Direction, String?) _generateCandidate(
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
  final stopwatch = Stopwatch()..start();

  var tries = 0;
  for (final word in shuffledWords) {
    if (tries >= 1000 || stopwatch.elapsed >= const Duration(seconds: 10)) {
      break;
    }

    for (final (idx, wordCharacter) in word.characters.indexed) {
      tries++;
      if (tries > 1000) break;

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
      if (candidate != null) return (start, direction, word);
    }
  }

  return (location, direction, null);
}
