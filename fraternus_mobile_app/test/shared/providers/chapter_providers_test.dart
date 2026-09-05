import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/shared/data/chapter_repository.dart';
import 'package:fraternus_mobile_app/shared/providers/chapter_providers.dart';

void main() {
  test('chaptersProvider sorts the repository result by display name', () async {
    final container = ProviderContainer(
      overrides: [
        chapterRepositoryProvider.overrideWithValue(const StaticChapterRepository()),
      ],
    );
    addTearDown(container.dispose);

    final chapters = await container.read(chaptersProvider.future);

    // seedChapters is authored in a non-alphabetical order (St. Philips,
    // Sacred Heart, Holy Trinity) so this also pins the sort itself, not
    // just the pass-through.
    expect(
      chapters.map((chapter) => chapter.displayName),
      [
        'Holy Trinity - Memphis, TN',
        'Sacred Heart - Nashville, TN',
        'St. Philips Franklin - Franklin, TN',
      ],
    );
  });
}
