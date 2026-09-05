import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/supabase_provider.dart';
import '../data/temperament_quiz_repository.dart';
import '../models/temperament_quiz_question.dart';

part 'temperament_quiz_providers.g.dart';

@riverpod
TemperamentQuizRepository temperamentQuizRepository(Ref ref) {
  return SupabaseTemperamentQuizRepository(ref.watch(supabaseClientProvider));
}

@riverpod
Future<List<TemperamentQuizQuestion>> temperamentQuizQuestions(Ref ref) {
  return ref.watch(temperamentQuizRepositoryProvider).fetchQuestions();
}
