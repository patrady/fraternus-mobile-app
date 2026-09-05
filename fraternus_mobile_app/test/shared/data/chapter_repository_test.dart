import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/shared/data/chapter_repository.dart';
import 'package:fraternus_mobile_app/shared/models/chapter.dart';

void main() {
  test('StaticChapterRepository returns the seed chapters', () async {
    const repository = StaticChapterRepository();

    final chapters = await repository.fetchChapters();

    expect(chapters, equals(seedChapters));
  });
}
