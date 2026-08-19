import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chapter.dart';

/// Source of the Chapter directory — same seam as every other XRepository
/// in this app.
abstract class ChapterRepository {
  Future<List<Chapter>> fetchChapters();
}

/// Backing data for tests/Widgetbook — see [seedChapters]'s doc comment.
class StaticChapterRepository implements ChapterRepository {
  const StaticChapterRepository();

  @override
  Future<List<Chapter>> fetchChapters() async => seedChapters;
}

class SupabaseChapterRepository implements ChapterRepository {
  SupabaseChapterRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Chapter>> fetchChapters() async {
    final rows = await _client.from('chapters').select().order('name');
    return [for (final row in rows) Chapter.fromJson(row)];
  }
}
