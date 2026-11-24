import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import 'package:generate_crossword/model.dart' as model;
import 'package:generate_crossword/providers.dart';

class CrosswordWidget extends ConsumerWidget {
  const CrosswordWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = ref.watch(sizeProvider);
    return TableView.builder(
      columnCount: size.width,
      rowCount: size.height,
      columnBuilder: (index) => const TableSpan(extent: FixedTableSpanExtent(32)),
      rowBuilder: (index) => const TableSpan(extent: FixedTableSpanExtent(32)),
      cellBuilder: _buildCell,
    );
  }

  TableViewCell _buildCell(BuildContext context, TableVicinity vicinity) {
    final location = model.Location.at(vicinity.column, vicinity.row);

    return TableViewCell(
      child: Consumer(
        builder: (context, ref, _) {
          // Only rebuild this cell when the character at its location changes.
          final character = ref.watch(
            workQueueProvider.select(
              (workQueueAsync) => workQueueAsync.when(
                data: (workQueue) => workQueue.crossword.characters[location],
                error: (error, stackTrace) => null,
                loading: () => null,
              ),
            ),
          );

          // Only rebuild this cell when its membership in the search
          // frontier changes.
          final isExplorationCell = ref.watch(
            workQueueProvider.select(
              (workQueueAsync) => workQueueAsync.when(
                data: (workQueue) => workQueue.locationsToTry.containsKey(location),
                error: (error, stackTrace) => false,
                loading: () => false,
              ),
            ),
          );

          final colorScheme = Theme.of(context).colorScheme;
          var backgroundColor = Colors.transparent;
          Color? foregroundColor;
          if (isExplorationCell) {
            // Cells waiting to be explored are highlighted by inverting the
            // primary and onPrimary colors.
            backgroundColor = colorScheme.primary;
            foregroundColor = colorScheme.onPrimary;
          } else if (character != null) {
            backgroundColor = colorScheme.primaryContainer;
            foregroundColor = colorScheme.onPrimaryContainer;
          }

          final style = (Theme.of(context).textTheme.bodyMedium ?? const TextStyle())
              .copyWith(color: foregroundColor);

          return AnimatedContainer(
            duration: Durations.extralong1,
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            alignment: Alignment.center,
            child: AnimatedDefaultTextStyle(
              duration: Durations.extralong1,
              curve: Curves.easeInOut,
              style: style,
              child: Text(character?.character ?? ''),
            ),
          );
        },
      ),
    );
  }
}
