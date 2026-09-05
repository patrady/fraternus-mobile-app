/// Top-level route paths — the bottom-nav tab branches plus the auth flow
/// that gates them. Kept as plain string constants (not an enum) since
/// go_router's `GoRoute.path` and `context.go(...)` both want raw strings.
///
/// Nested segment constants (`kidsSegment`, `editSegment`, etc.) are the
/// single source of truth for those path pieces — `app_router.dart`'s
/// `GoRoute.path` values reference them directly instead of re-typing the
/// literal, so a rename here can't silently desync the two files.
abstract final class RoutePaths {
  static const welcome = '/welcome';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const signUpBrother = '$signUp/brother';
  static const signUpAccount = '$signUp/account';
  static const forgotPassword = '/forgot-password';

  static const today = '/today';
  static const guide = '/guide';
  static const challenge = '/challenge';
  static const events = '/events';
  static const debug = '/debug';

  static const profileSegment = 'profile';
  static const editSegment = 'edit';
  static const kidsSegment = 'kids';
  static const addSegment = 'add';
  static const remindersSegment = 'reminders';
  static const virtueSegment = 'virtue';
  static const temperamentSegment = 'temperament';
  static const temperamentQuizSegment = 'temperament-quiz';
  static const pastSegment = 'past';

  static const pastChallenges = '$challenge/$pastSegment';
  static const guideVirtue = '$guide/$virtueSegment';
  static const todayProfile = '$today/$profileSegment';
  static const todayProfileEdit = '$todayProfile/$editSegment';
  static const todayProfileKids = '$todayProfile/$kidsSegment';
  static const todayProfileKidsAdd = '$todayProfileKids/$addSegment';
  static const todayProfileReminders = '$todayProfile/$remindersSegment';

  static String eventDetail(String eventId) => '$events/$eventId';
  static String guideTemperament(String key) => '$guideVirtue/$temperamentSegment/$key';
  static String temperamentQuiz(String personKey) => '$guide/$temperamentQuizSegment/$personKey';
  static String todayProfileKidsEdit(String memberId) => '$todayProfileKids/$memberId';
}
