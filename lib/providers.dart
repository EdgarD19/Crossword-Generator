import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:generate_crossword/isolates.dart';
import 'package:generate_crossword/model.dart' as model;

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

@Riverpod(keepAlive: true)
class StartTime extends _$StartTime {
  @override
  DateTime? build() => null;

  void start() => state = DateTime.now();
}

@Riverpod(keepAlive: true)
class EndTime extends _$EndTime {
  @override
  DateTime? build() => null;

  void stop() => state = DateTime.now();

  void reset() => state = null;
}

@Riverpod(keepAlive: true)
class ShowDisplayInfo extends _$ShowDisplayInfo {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

enum BackgroundWorkers {
  one(1),
  two(2),
  four(4),
  eight(8),
  sixteen(16),
  thirtyTwo(32),
  sixtyFour(64),
  oneTwentyEight(128);

  const BackgroundWorkers(this.count);

  final int count;

  String get label => '$count workers';
}

@Riverpod(keepAlive: true)
class WorkerCount extends _$WorkerCount {
  @override
  BackgroundWorkers build() => BackgroundWorkers.four;

  void setWorkers(BackgroundWorkers workers) => state = workers;
}

/// Assumed fraction of the grid that is filled when the backtracking search
/// runs out of open intersections, used to estimate remaining time.
const _estimatedTotalCoverage = 0.54;

@riverpod
Duration expectedRemainingTime(Ref ref) {
  final startTime = ref.watch(startTimeProvider);
  final workQueue = ref.watch(workQueueProvider).asData?.value;

  if (startTime == null || workQueue == null || workQueue.isCompleted) {
    return Duration.zero;
  }

  final size = ref.watch(sizeProvider);
  final totalCells = size.width * size.height;
  final filled = workQueue.crossword.characters.length;
  final estimatedTargetCells = (totalCells * _estimatedTotalCoverage).round();

  final remainingCells = estimatedTargetCells - filled;
  final elapsed = DateTime.now().difference(startTime);
  if (remainingCells <= 0 || filled == 0 || elapsed.inMilliseconds == 0) {
    return Duration.zero;
  }

  final cellsPerMillisecond = filled / elapsed.inMilliseconds;
  return Duration(milliseconds: (remainingCells / cellsPerMillisecond).round());
}

@riverpod
class DisplayInfo extends _$DisplayInfo {
  @override
  model.DisplayInfo build() {
    // Only rebuild when the formatted statistics actually change.
    return ref.watch(
      workQueueProvider.select(
        (workQueueAsync) => workQueueAsync.when(
          data: (workQueue) => model.DisplayInfo.from(workQueue: workQueue),
          error: (error, stackTrace) => model.DisplayInfo.empty,
          loading: () => model.DisplayInfo.empty,
        ),
      ),
    );
  }
}

@riverpod
Stream<model.WorkQueue> workQueue(Ref ref) async* {
  final size = ref.watch(sizeProvider);
  final wordList = await ref.watch(wordListProvider.future);

  ref.read(endTimeProvider.notifier).reset();
  ref.read(startTimeProvider.notifier).start();

  // Watching the worker count restarts generation with the new group size,
  // just like changing the grid size does.
  yield* exploreCrosswordSolutions(
    crossword: model.Crossword.crossword(width: size.width, height: size.height),
    wordList: wordList,
    maxWorkerCount: ref.watch(workerCountProvider).count,
  );

  ref.read(endTimeProvider.notifier).stop();
}

