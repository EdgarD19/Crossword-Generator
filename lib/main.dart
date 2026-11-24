import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:generate_crossword/widgets/crossword_generator_app.dart';

void main() {
  runApp(const CrosswordBuilderApp());
}

class CrosswordBuilderApp extends StatelessWidget {
  const CrosswordBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Crossword Builder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.blueGrey,
          brightness: Brightness.light,
        ),
        home: const CrosswordGeneratorApp(),
      ),
    );
  }
}
