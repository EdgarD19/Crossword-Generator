import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:generate_crossword/providers.dart';

class CrosswordGeneratorApp extends StatelessWidget {
  const CrosswordGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return _EagerInitialization(
      child: Scaffold(
        appBar: AppBar(title: const Text('Crossword Generator')),
        body: const _WordListView(),
      ),
    );
  }
}

/// Watches [wordListProvider] near the root of the widget tree so that the
/// dictionary starts loading eagerly at app startup, instead of lazily on
/// first read.
class _EagerInitialization extends ConsumerWidget {
  const _EagerInitialization({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(wordListProvider);
    return child;
  }
}

class _WordListView extends ConsumerWidget {
  const _WordListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordListAsync = ref.watch(wordListProvider);
    return wordListAsync.when(
      data: (wordList) => ListView.builder(
        itemCount: wordList.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(wordList.elementAt(index)));
        },
      ),
      error: (error, stackTrace) => Center(child: Text('$error')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
