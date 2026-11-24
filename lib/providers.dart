import 'dart:convert';
import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:generate_crossword/model.dart' as model;
import 'package:generate_crossword/utils.dart';

part 'providers.g.dart';

@riverpod
Future<BuiltSet<String>> wordList(Ref ref) async {
  final re = RegExp(r'^[a-z]+$');
  final words = await rootBundle.loadString('assets/words.txt');
  return const LineSplitter()
      .convert(words)
      .toBuiltSet()
      .rebuild(
        (b) => b
          ..map((word) => word.toLowerCase().trim())
          ..where((word) => word.length > 2)
          ..where((word) => re.hasMatch(word)),
      );
}

enum CrosswordSize {
  small(20, 11),
  medium(40, 22),
  large(80, 44),
  xlarge(160, 88),
  xxlarge(500, 500);

  const CrosswordSize(this.width, this.height);

  final int width;
  final int height;

  String get label => '$width x $height';
}

@Riverpod(keepAlive: true)
class Size extends _$Size {
  @override
  CrosswordSize build() => CrosswordSize.medium;

  void setSize(CrosswordSize size) => state = size;
}

@riverpod
Stream<model.Crossword> crossword(Ref ref) async* {
  final size = ref.watch(sizeProvider);
  final wordList = await ref.watch(wordListProvider.future);

  final random = Random();
  final targetFilled = (size.width * size.height * 0.8).round();

  var crossword = model.Crossword.crossword(width: size.width, height: size.height);
  yield crossword;

  while (crossword.characters.length < targetFilled) {
    final direction = model.Direction.values[random.nextInt(model.Direction.values.length)];
    final word = wordList.randomElement();
    final location = model.Location.at(
      random.nextInt(size.width),
      random.nextInt(size.height),
    );

    crossword = crossword.addWord(location: location, word: word, direction: direction);
    yield crossword;

    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

