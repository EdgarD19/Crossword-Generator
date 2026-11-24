import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:characters/characters.dart';
import 'package:intl/intl.dart';

part 'model.g.dart';

/// A 0-based (x, y) coordinate in a [Crossword].
abstract class Location implements Built<Location, LocationBuilder> {
  Location._();

  factory Location([void Function(LocationBuilder b) updates]) = _$Location;

  factory Location.at(int x, int y) => Location(
    (b) => b
      ..x = x
      ..y = y,
  );

  int get x;
  int get y;

  Location get left => Location.at(x - 1, y);
  Location get right => Location.at(x + 1, y);
  Location get up => Location.at(x, y - 1);
  Location get down => Location.at(x, y + 1);

  Location leftOffset(int offset) => Location.at(x - offset, y);
  Location rightOffset(int offset) => Location.at(x + offset, y);
  Location upOffset(int offset) => Location.at(x, y - offset);
  Location downOffset(int offset) => Location.at(x, y + offset);

  String prettyPrint() => 'Location($x, $y)';
}

/// The orientation of a [CrosswordWord] in the grid.
enum Direction {
  across,
  down;

  @override
  String toString() => name;
}

/// A word placed in a [Crossword] at a [Location] in a [Direction].
abstract class CrosswordWord implements Built<CrosswordWord, CrosswordWordBuilder> {
  CrosswordWord._();

  factory CrosswordWord([void Function(CrosswordWordBuilder b) updates]) = _$CrosswordWord;

  factory CrosswordWord.word({
    required String word,
    required Location location,
    required Direction direction,
  }) => CrosswordWord(
    (b) => b
      ..word = word
      ..location.replace(location)
      ..direction = direction,
  );

  String get word;
  Location get location;
  Direction get direction;

  static int locationComparator(CrosswordWord a, CrosswordWord b) {
    final byX = a.location.x.compareTo(b.location.x);
    if (byX != 0) return byX;
    final byY = a.location.y.compareTo(b.location.y);
    if (byY != 0) return byY;
    return a.direction.index.compareTo(b.direction.index);
  }
}

/// A single character cell in a [Crossword], tracking which words cross it.
abstract class CrosswordCharacter implements Built<CrosswordCharacter, CrosswordCharacterBuilder> {
  CrosswordCharacter._();

  factory CrosswordCharacter([void Function(CrosswordCharacterBuilder b) updates]) = _$CrosswordCharacter;

  factory CrosswordCharacter.character({
    required String character,
    CrosswordWord? acrossWord,
    CrosswordWord? downWord,
  }) => CrosswordCharacter(
    (b) => b
      ..character = character
      ..acrossWord = acrossWord?.toBuilder()
      ..downWord = downWord?.toBuilder(),
  );

  String get character;

  CrosswordWord? get acrossWord;

  CrosswordWord? get downWord;
}

/// An immutable crossword grid of [CrosswordWord]s.
abstract class Crossword implements Built<Crossword, CrosswordBuilder> {
  Crossword._();

  factory Crossword([void Function(CrosswordBuilder b) updates]) = _$Crossword;

  factory Crossword.crossword({required int width, required int height}) => Crossword(
    (b) => b
      ..width = width
      ..height = height,
  );

  int get width;
  int get height;
  BuiltList<CrosswordWord> get words;

  /// A map from (x, y) [Location] to the [CrosswordCharacter] placed there.
  BuiltMap<Location, CrosswordCharacter> get characters;

  Crossword? addWord({
    required Location location,
    required String word,
    required Direction direction,
  }) {
    // Reject duplicate words.
    if (words.any((placed) => placed.word == word)) return null;

    // Reject words that conflict with an existing character or a word in the
    // same direction, tracking whether the placement overlaps the crossword.
    var overlaps = false;
    for (final (idx, character) in word.characters.indexed) {
      final cellLocation = switch (direction) {
        Direction.across => location.rightOffset(idx),
        Direction.down => location.downOffset(idx),
      };
      final existing = characters[cellLocation];
      if (existing == null) continue;
      if (existing.character != character) return null;
      final sameDirectionWord = switch (direction) {
        Direction.across => existing.acrossWord,
        Direction.down => existing.downWord,
      };
      if (sameDirectionWord != null) return null;
      overlaps = true;
    }

    // After the first word, every new word must overlap an existing word.
    if (words.isNotEmpty && !overlaps) return null;

    final candidate = rebuild(
      (b) => b.words.add(
        CrosswordWord.word(word: word, location: location, direction: direction),
      ),
    );

    // Reject candidates that violate English crossword constraints.
    if (!candidate.valid) return null;
    return candidate;
  }

  /// Whether this crossword satisfies English crossword constraints:
  ///
  /// 1. No duplicate words.
  /// 2. Every character stays within `[0, width)` and `[0, height)` and is
  ///    part of at least one word.
  /// 3. Horizontally adjacent characters share the same `acrossWord`, when
  ///    either has one (prevents parallel words colliding side by side).
  /// 4. Vertically adjacent characters share the same `downWord`, when
  ///    either has one.
  bool get valid {
    // 1. No duplicate words.
    final uniqueWords = words.map((word) => word.word).toSet();
    if (uniqueWords.length != words.length) return false;

    for (final MapEntry(key: location, value: character) in characters.entries) {
      // 2. Characters stay within grid bounds...
      if (location.x < 0 || location.x >= width || location.y < 0 || location.y >= height) {
        return false;
      }

      // ...and are part of at least one word.
      if (character.acrossWord == null && character.downWord == null) return false;

      // 3. Horizontal neighbors must share the same across word, when either
      //    has one (prevents unwanted parallel collisions side by side).
      final rightNeighbor = characters[location.right];
      if (rightNeighbor != null && rightNeighbor.acrossWord != character.acrossWord) {
        return false;
      }

      // 4. Vertical neighbors must share the same down word, when either
      //    has one.
      final downNeighbor = characters[location.down];
      if (downNeighbor != null && downNeighbor.downWord != character.downWord) {
        return false;
      }
    }

    return true;
  }

  @BuiltValueHook(finalizeBuilder: true)
  static void _fillCharacters(CrosswordBuilder b) {
    b.characters.clear();

    for (final word in b.words.build()) {
      for (final (idx, character) in word.word.characters.indexed) {
        switch (word.direction) {
          case Direction.across:
            b.characters.updateValue(
              word.location.rightOffset(idx),
              (character) => character.rebuild((bInner) => bInner.acrossWord.replace(word)),
              ifAbsent: () => CrosswordCharacter.character(acrossWord: word, character: character),
            );
          case Direction.down:
            b.characters.updateValue(
              word.location.downOffset(idx),
              (character) => character.rebuild((bInner) => bInner.downWord.replace(word)),
              ifAbsent: () => CrosswordCharacter.character(downWord: word, character: character),
            );
        }
      }
    }
  }

  String prettyPrintCrossword() {
    final buffer = StringBuffer();
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final character = characters[Location.at(x, y)];
        buffer.write(character?.character ?? '·');
      }
      buffer.writeln();
    }
    return buffer.toString();
  }
}

@SerializersFor([Location, Crossword, CrosswordWord, CrosswordCharacter, WorkQueue, DisplayInfo])
final Serializers serializers = _$serializers;

/// Real-time generation statistics for the floating HUD overlay.
abstract class DisplayInfo implements Built<DisplayInfo, DisplayInfoBuilder> {
  DisplayInfo._();

  factory DisplayInfo([void Function(DisplayInfoBuilder b) updates]) = _$DisplayInfo;

  static DisplayInfo get empty => DisplayInfo(
    (b) => b
      ..wordsInGridCount = '0'
      ..candidateWordsCount = '0'
      ..locationsToExploreCount = '0'
      ..knownBadLocationsCount = '0'
      ..gridFilledPercentage = '0',
  );

  factory DisplayInfo.from({required WorkQueue workQueue}) {
    final format = NumberFormat.decimalPattern();
    final crossword = workQueue.crossword;
    final totalCells = crossword.width * crossword.height;
    final gridFilledPercentage = totalCells == 0
        ? 0.0
        : crossword.characters.length / totalCells * 100;

    return DisplayInfo(
      (b) => b
        ..wordsInGridCount = format.format(crossword.words.length)
        ..candidateWordsCount = format.format(workQueue.candidateWords.length)
        ..locationsToExploreCount = format.format(workQueue.locationsToTry.length)
        ..knownBadLocationsCount = format.format(workQueue.badLocations.length)
        ..gridFilledPercentage = format.format(gridFilledPercentage),
    );
  }

  String get wordsInGridCount;
  String get candidateWordsCount;
  String get locationsToExploreCount;
  String get knownBadLocationsCount;
  String get gridFilledPercentage;
}

/// The backtracking search frontier for crossword generation.
///
/// Tracks the [Crossword] built so far, the open intersection cells to try
/// extending with a crossing word (`locationsToTry`), the cells known to be
/// dead ends (`badLocations`), and the dictionary of `candidateWords`.
abstract class WorkQueue implements Built<WorkQueue, WorkQueueBuilder> {
  WorkQueue._();

  factory WorkQueue([void Function(WorkQueueBuilder b) updates]) = _$WorkQueue;

  Crossword get crossword;

  /// Open cells that may still accept a crossing word, mapped to the
  /// [Direction] the crossing word must take.
  BuiltMap<Location, Direction> get locationsToTry;

  /// Cells that failed to accept any candidate word and are dead ends.
  BuiltSet<Location> get badLocations;

  BuiltSet<String> get candidateWords;

  bool get isCompleted => locationsToTry.isEmpty || candidateWords.isEmpty;

  /// Seeds a queue from [crossword]: when the crossword is empty the only
  /// location to try is [startLocation]; otherwise every placed character
  /// that belongs to exactly one word and is not blocked by a parallel
  /// neighbor becomes a candidate intersection for a crossing word in the
  /// perpendicular direction.
  static WorkQueue from({
    required Crossword crossword,
    required Iterable<String> candidateWords,
    required Location startLocation,
  }) {
    final builder = WorkQueueBuilder()
      ..crossword = crossword.toBuilder()
      ..candidateWords = BuiltSet<String>(candidateWords).toBuilder()
      ..badLocations = SetBuilder<Location>();

    if (crossword.words.isEmpty) {
      builder.locationsToTry[startLocation] = Direction.across;
    } else {
      builder.locationsToTry.addAll(_openIntersections(crossword, builder.badLocations.build()));
    }

    return builder.build();
  }

  /// Marks [location] as a known bad location and drops it from the queue.
  WorkQueue remove(Location location) => rebuild(
    (b) => b
      ..locationsToTry.remove(location)
      ..badLocations.add(location),
  );

  /// Recomputes the open intersections from [crossword], preserving known
  /// bad locations and candidate words.
  WorkQueue updateFrom(Crossword crossword) => rebuild(
    (b) => b
      ..crossword = crossword.toBuilder()
      ..locationsToTry = MapBuilder(_openIntersections(crossword, badLocations)),
  );

  /// Cells belonging to exactly one word whose perpendicular neighbors leave
  /// room for a crossing word, mapped to the required crossing direction.
  static Map<Location, Direction> _openIntersections(
    Crossword crossword,
    BuiltSet<Location> badLocations,
  ) {
    final locationsToTry = <Location, Direction>{};

    for (final MapEntry(key: location, value: character) in crossword.characters.entries) {
      final direction = switch ((character.acrossWord, character.downWord)) {
        (null, null) => throw StateError('Character is not part of a word'),
        (null, _) => Direction.across,
        (_, null) => Direction.down,
        (_, _) => null, // Complete intersection: no room for another word.
      };
      if (direction == null) continue;

      // A neighbor on the start side of the crossing direction blocks the
      // placement of any perpendicular word through this cell.
      final blocked = switch (direction) {
        Direction.across => crossword.characters[location.left] != null,
        Direction.down => crossword.characters[location.up] != null,
      };
      if (blocked) continue;

      if (badLocations.contains(location)) continue;
      locationsToTry[location] = direction;
    }

    return locationsToTry;
  }
}
