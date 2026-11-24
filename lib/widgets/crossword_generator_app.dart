import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:generate_crossword/providers.dart';
import 'package:generate_crossword/widgets/crossword_info_widget.dart';
import 'package:generate_crossword/widgets/crossword_widget.dart';

class CrosswordGeneratorApp extends StatelessWidget {
  const CrosswordGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return _EagerInitialization(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crossword Generator'),
          actions: const [_CrosswordGeneratorMenu()],
        ),
        body: Consumer(
          builder: (context, ref, _) {
            final showDisplayInfo = ref.watch(showDisplayInfoProvider);
            return Stack(
              children: [
                const CrosswordWidget(),
                if (showDisplayInfo) const CrosswordInfoWidget(),
              ],
            );
          },
        ),
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

/// A [MenuAnchor] in the [AppBar] to switch the [CrosswordSize] of the grid
/// and toggle the statistics overlay.
class _CrosswordGeneratorMenu extends ConsumerStatefulWidget {
  const _CrosswordGeneratorMenu();

  @override
  ConsumerState<_CrosswordGeneratorMenu> createState() => _CrosswordGeneratorMenuState();
}

class _CrosswordGeneratorMenuState extends ConsumerState<_CrosswordGeneratorMenu> {
  final MenuController _controller = MenuController();

  @override
  Widget build(BuildContext context) {
    final currentSize = ref.watch(sizeProvider);
    final currentWorkers = ref.watch(workerCountProvider);
    final showDisplayInfo = ref.watch(showDisplayInfoProvider);

    return MenuAnchor(
      controller: _controller,
      menuChildren: [
        for (final size in CrosswordSize.values)
          MenuItemButton(
            onPressed: () => ref.read(sizeProvider.notifier).setSize(size),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (size == currentSize)
                    const Icon(Icons.check, size: 18)
                  else
                    const SizedBox(width: 18),
                  const SizedBox(width: 8),
                  Text(size.label),
                ],
              ),
            ),
          ),
        for (final workers in BackgroundWorkers.values)
          MenuItemButton(
            onPressed: () => ref.read(workerCountProvider.notifier).setWorkers(workers),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (workers == currentWorkers)
                    const Icon(Icons.check, size: 18)
                  else
                    const SizedBox(width: 18),
                  const SizedBox(width: 8),
                  Text(workers.label),
                ],
              ),
            ),
          ),
        MenuItemButton(
          onPressed: () => ref.read(showDisplayInfoProvider.notifier).toggle(),
          leadingIcon: Icon(
            showDisplayInfo ? Icons.visibility : Icons.visibility_off,
            size: 18,
          ),
          child: const Text('Display Info'),
        ),
      ],
      builder: (context, controller, child) => IconButton(
        onPressed: () => controller.open(),
        icon: const Icon(Icons.grid_on),
        tooltip: 'Grid size',
      ),
    );
  }
}
