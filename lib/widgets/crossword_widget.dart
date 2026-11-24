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
            crosswordProvider.select(
              (crosswordAsync) => crosswordAsync.when(
                data: (crossword) => crossword.characters[location],
                error: (error, stackTrace) => null,
                loading: () => null,
              ),
            ),
          );

          return Container(
            decoration: BoxDecoration(
              color: character == null
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.primaryContainer,
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            alignment: Alignment.center,
            child: Text(
              character?.character ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        },
      ),
    );
  }
}
