// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temperament_quiz_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(temperamentQuizRepository)
const temperamentQuizRepositoryProvider = TemperamentQuizRepositoryProvider._();

final class TemperamentQuizRepositoryProvider
    extends
        $FunctionalProvider<
          TemperamentQuizRepository,
          TemperamentQuizRepository,
          TemperamentQuizRepository
        >
    with $Provider<TemperamentQuizRepository> {
  const TemperamentQuizRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'temperamentQuizRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$temperamentQuizRepositoryHash();

  @$internal
  @override
  $ProviderElement<TemperamentQuizRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TemperamentQuizRepository create(Ref ref) {
    return temperamentQuizRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TemperamentQuizRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TemperamentQuizRepository>(value),
    );
  }
}

String _$temperamentQuizRepositoryHash() =>
    r'1a3a33f0adcd2640c5c7d33ae749a9796b87a0ec';

@ProviderFor(temperamentQuizQuestions)
const temperamentQuizQuestionsProvider = TemperamentQuizQuestionsProvider._();

final class TemperamentQuizQuestionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TemperamentQuizQuestion>>,
          List<TemperamentQuizQuestion>,
          FutureOr<List<TemperamentQuizQuestion>>
        >
    with
        $FutureModifier<List<TemperamentQuizQuestion>>,
        $FutureProvider<List<TemperamentQuizQuestion>> {
  const TemperamentQuizQuestionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'temperamentQuizQuestionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$temperamentQuizQuestionsHash();

  @$internal
  @override
  $FutureProviderElement<List<TemperamentQuizQuestion>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TemperamentQuizQuestion>> create(Ref ref) {
    return temperamentQuizQuestions(ref);
  }
}

String _$temperamentQuizQuestionsHash() =>
    r'114dda79b634acd594e3246b1f50333dd1fad087';
