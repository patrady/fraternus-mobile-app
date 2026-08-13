/// Top-level route paths — one per bottom-nav tab branch. Kept as plain
/// string constants (not an enum) since go_router's `GoRoute.path` and
/// `context.go(...)` both want raw strings.
abstract final class RoutePaths {
  static const today = '/today';
  static const guide = '/guide';
  static const challenge = '/challenge';
  static const events = '/events';
  static const pastChallenges = '$challenge/past';
  static const guideVirtue = '$guide/virtue';
  static const todayProfile = '$today/profile';
  static const todayProfileEdit = '$todayProfile/edit';
  static const todayProfileKids = '$todayProfile/kids';
  static const todayProfileKidsAdd = '$todayProfileKids/add';
  static const todayProfileReminders = '$todayProfile/reminders';

  static String eventDetail(String eventId) => '$events/$eventId';
  static String guideTemperament(String key) => '$guideVirtue/temperament/$key';
  static String temperamentQuiz(String personKey) => '$guide/temperament-quiz/$personKey';
  static String todayProfileKidsEdit(String memberId) => '$todayProfileKids/$memberId';
}
