import 'dart:math';

import 'package:built_collection/built_collection.dart';

extension RandomElements<E> on BuiltSet<E> {
  E randomElement() => elementAt(Random().nextInt(length));
}
