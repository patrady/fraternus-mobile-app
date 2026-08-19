// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Swap this provider's implementation to change where the Chapter
/// directory's data comes from — nothing downstream needs to change.

@ProviderFor(chapterRepository)
const chapterRepositoryProvider = ChapterRepositoryProvider._();

/// Swap this provider's implementation to change where the Chapter
/// directory's data comes from — nothing downstream needs to change.

final class ChapterRepositoryProvider
    extends
        $FunctionalProvider<
          ChapterRepository,
          ChapterRepository,
          ChapterRepository
        >
    with $Provider<ChapterRepository> {
  /// Swap this provider's implementation to change where the Chapter
  /// directory's data comes from — nothing downstream needs to change.
  const ChapterRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chapterRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chapterRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChapterRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChapterRepository create(Ref ref) {
    return chapterRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChapterRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChapterRepository>(value),
    );
  }
}

String _$chapterRepositoryHash() => r'afab83811c4f3bf98ad1294789d3f17486a73935';

/// The full Chapter directory — read on both the pre-auth signup screens
/// (chapters are non-sensitive public data, readable by the anon role, see
/// the "chapters_anon_read" migration) and the post-auth profile/child
/// forms.

@ProviderFor(chapters)
const chaptersProvider = ChaptersProvider._();

/// The full Chapter directory — read on both the pre-auth signup screens
/// (chapters are non-sensitive public data, readable by the anon role, see
/// the "chapters_anon_read" migration) and the post-auth profile/child
/// forms.

final class ChaptersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Chapter>>,
          List<Chapter>,
          FutureOr<List<Chapter>>
        >
    with $FutureModifier<List<Chapter>>, $FutureProvider<List<Chapter>> {
  /// The full Chapter directory — read on both the pre-auth signup screens
  /// (chapters are non-sensitive public data, readable by the anon role, see
  /// the "chapters_anon_read" migration) and the post-auth profile/child
  /// forms.
  const ChaptersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chaptersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chaptersHash();

  @$internal
  @override
  $FutureProviderElement<List<Chapter>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Chapter>> create(Ref ref) {
    return chapters(ref);
  }
}

String _$chaptersHash() => r'1a400935f1c1c1bb84788adf5674e9655ef66370';
