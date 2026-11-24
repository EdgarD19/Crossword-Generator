import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:generate_crossword/providers.dart';
import 'package:generate_crossword/utils.dart';
import 'package:generate_crossword/widgets/ticker_builder.dart';

class CrosswordInfoWidget extends ConsumerWidget {
  const CrosswordInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayInfo = ref.watch(displayInfoProvider);
    final startTime = ref.watch(startTimeProvider);
    final endTime = ref.watch(endTimeProvider);
    final expectedRemainingTime = ref.watch(expectedRemainingTimeProvider);

    return Align(
      alignment: Alignment.bottomRight,
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: TickerBuilder(
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CrosswordInfoRichText(
                  label: 'Words in grid',
                  value: displayInfo.wordsInGridCount,
                ),
                _CrosswordInfoRichText(
                  label: 'Candidate words',
                  value: displayInfo.candidateWordsCount,
                ),
                _CrosswordInfoRichText(
                  label: 'Locations to explore',
                  value: displayInfo.locationsToExploreCount,
                ),
                _CrosswordInfoRichText(
                  label: 'Known bad locations',
                  value: displayInfo.knownBadLocationsCount,
                ),
                _CrosswordInfoRichText(
                  label: 'Grid filled',
                  value: '${displayInfo.gridFilledPercentage}%',
                ),
                switch ((startTime, endTime)) {
                  (null, _) => const _CrosswordInfoRichText(
                    label: 'Time elapsed',
                    value: 'Not started yet',
                  ),
                  (DateTime start, null) => _CrosswordInfoRichText(
                    label: 'Time elapsed',
                    value: DateTime.now().difference(start).formatted,
                  ),
                  (DateTime start, DateTime end) => _CrosswordInfoRichText(
                    label: 'Completed in',
                    value: end.difference(start).formatted,
                  ),
                },
                _CrosswordInfoRichText(
                  label: 'Expected remaining time',
                  value: expectedRemainingTime.formatted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CrosswordInfoRichText extends StatelessWidget {
  const _CrosswordInfoRichText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$label: ', style: Theme.of(context).textTheme.bodyMedium),
          TextSpan(
            text: value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
