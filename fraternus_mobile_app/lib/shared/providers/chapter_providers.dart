import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/supabase_provider.dart';
import '../data/chapter_repository.dart';
import '../models/chapter.dart';

part 'chapter_providers.g.dart';

/// Swap this provider's implementation to change where the Chapter
/// directory's data comes from — nothing downstream needs to change.
@riverpod
ChapterRepository chapterRepository(Ref ref) {
  return SupabaseChapterRepository(ref.watch(supabaseClientProvider));
}

/// The full Chapter directory — read on both the pre-auth signup screens
/// (chapters are non-sensitive public data, readable by the anon role, see
/// the "chapters_anon_read" migration) and the post-auth profile/child
/// forms.
@riverpod
Future<List<Chapter>> chapters(Ref ref) {
  return ref.watch(chapterRepositoryProvider).fetchChapters();
}
