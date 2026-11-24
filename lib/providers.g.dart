// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$wordListHash() => r'07003444d7241448561b638500001e31610b4717';

/// See also [wordList].
@ProviderFor(wordList)
final wordListProvider = AutoDisposeFutureProvider<BuiltSet<String>>.internal(
  wordList,
  name: r'wordListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$wordListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WordListRef = AutoDisposeFutureProviderRef<BuiltSet<String>>;
String _$expectedRemainingTimeHash() =>
    r'b381bf6989d1399a6f93dfc2adbbc88927bd0bf3';

/// See also [expectedRemainingTime].
@ProviderFor(expectedRemainingTime)
final expectedRemainingTimeProvider = AutoDisposeProvider<Duration>.internal(
  expectedRemainingTime,
  name: r'expectedRemainingTimeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$expectedRemainingTimeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExpectedRemainingTimeRef = AutoDisposeProviderRef<Duration>;
String _$workQueueHash() => r'24598e65efcbee6de252f66c7b9a1424a2544369';

/// See also [workQueue].
@ProviderFor(workQueue)
final workQueueProvider = AutoDisposeStreamProvider<model.WorkQueue>.internal(
  workQueue,
  name: r'workQueueProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$workQueueHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WorkQueueRef = AutoDisposeStreamProviderRef<model.WorkQueue>;
String _$sizeHash() => r'eb133b42965790fb371fcf8cd0f69b29b5199947';

/// See also [Size].
@ProviderFor(Size)
final sizeProvider = NotifierProvider<Size, CrosswordSize>.internal(
  Size.new,
  name: r'sizeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$sizeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Size = Notifier<CrosswordSize>;
String _$startTimeHash() => r'aced96ef5d2ace2a4e9bee398a0165f3fef010d2';

/// See also [StartTime].
@ProviderFor(StartTime)
final startTimeProvider = NotifierProvider<StartTime, DateTime?>.internal(
  StartTime.new,
  name: r'startTimeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$startTimeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StartTime = Notifier<DateTime?>;
String _$endTimeHash() => r'8f54971ae9aff91e66c774112256ccfce12a5f6f';

/// See also [EndTime].
@ProviderFor(EndTime)
final endTimeProvider = NotifierProvider<EndTime, DateTime?>.internal(
  EndTime.new,
  name: r'endTimeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$endTimeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EndTime = Notifier<DateTime?>;
String _$showDisplayInfoHash() => r'b2431424d49a736527acd8bbffc93d2abf4935a2';

/// See also [ShowDisplayInfo].
@ProviderFor(ShowDisplayInfo)
final showDisplayInfoProvider =
    NotifierProvider<ShowDisplayInfo, bool>.internal(
  ShowDisplayInfo.new,
  name: r'showDisplayInfoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$showDisplayInfoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ShowDisplayInfo = Notifier<bool>;
String _$displayInfoHash() => r'e13b025e298cda3bbeb1fd778fd080a7aa44a9fc';

/// See also [DisplayInfo].
@ProviderFor(DisplayInfo)
final displayInfoProvider =
    AutoDisposeNotifierProvider<DisplayInfo, model.DisplayInfo>.internal(
  DisplayInfo.new,
  name: r'displayInfoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$displayInfoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DisplayInfo = AutoDisposeNotifier<model.DisplayInfo>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
