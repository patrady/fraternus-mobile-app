import '../models/app_user.dart';
import '../models/member.dart';
import '../models/reminder_setting.dart';
import '../models/user_member_association.dart';

/// Source of the Profile tab's data. Returning a [Future] here — even
/// though [StaticProfileRepository] resolves instantly — is the deliberate
/// seam: swapping to a real API call later only means changing the
/// implementation, not this interface, the providers that watch it, or the
/// screens.
abstract class ProfileRepository {
  Future<AppUser> fetchCurrentUser();
  Future<List<Member>> fetchMembers();
  Future<List<UserMemberAssociation>> fetchAssociations();
  Future<List<ReminderGroup>> fetchReminders();
}

/// Hardcoded stand-in for real content, matching the reference screenshots
/// and the User/Member/UserMemberAssociation shape from
/// docs/app_concept.md. Ids reuse the 'you'/'jack'/'thomas' strings other
/// features already use for narrative continuity only — no actual
/// cross-feature data coupling.
class StaticProfileRepository implements ProfileRepository {
  const StaticProfileRepository();

  static const _userId = 'user-john';

  // AppUser.email is sourced from the Self-relationship Member's own
  // email — kept as one constant here so both stay in sync in this seed.
  static const _selfEmail = 'john.smith@example.com';

  @override
  Future<AppUser> fetchCurrentUser() async {
    final joinedAt = DateTime.now().subtract(const Duration(days: 400));
    return AppUser(
      id: _userId,
      firstName: 'John',
      lastName: 'Smith',
      email: _selfEmail,
      createdAt: joinedAt,
      lastModifiedAt: joinedAt,
    );
  }

  @override
  Future<List<Member>> fetchMembers() async {
    final now = DateTime.now();
    final joinedAt = now.subtract(const Duration(days: 400));
    return [
      Member(
        id: 'you',
        firstName: 'John',
        lastName: 'Smith',
        role: MemberRole.captain,
        chapterId: 'st-philips-franklin',
        birthday: DateTime(now.year - 42, 3, 14),
        email: _selfEmail,
        createdAt: joinedAt,
        lastModifiedAt: joinedAt,
      ),
      Member(
        id: 'jack',
        firstName: 'Jack',
        lastName: 'Smith',
        role: MemberRole.brother,
        chapterId: 'st-philips-franklin',
        birthday: DateTime(now.year - 12, 5, 12),
        createdAt: joinedAt,
        lastModifiedAt: joinedAt,
      ),
      Member(
        id: 'thomas',
        firstName: 'Thomas',
        lastName: 'Smith',
        role: MemberRole.brother,
        chapterId: 'st-philips-franklin',
        birthday: DateTime(now.year - 9, 9, 3),
        createdAt: joinedAt,
        lastModifiedAt: joinedAt,
      ),
    ];
  }

  @override
  Future<List<UserMemberAssociation>> fetchAssociations() async {
    final joinedAt = DateTime.now().subtract(const Duration(days: 400));
    return [
      UserMemberAssociation(
        id: '$_userId-you',
        userId: _userId,
        memberId: 'you',
        relationship: AssociationRelationship.self,
        createdAt: joinedAt,
        lastModifiedAt: joinedAt,
      ),
      // Jack (12) and Thomas (9) are both under 13 — COPPA consent applies
      // and has already been granted in this seed.
      UserMemberAssociation(
        id: '$_userId-jack',
        userId: _userId,
        memberId: 'jack',
        relationship: AssociationRelationship.guardian,
        consentStatus: ConsentStatus.granted,
        consentDate: joinedAt,
        consentMethod: 'email confirmation',
        createdAt: joinedAt,
        lastModifiedAt: joinedAt,
      ),
      UserMemberAssociation(
        id: '$_userId-thomas',
        userId: _userId,
        memberId: 'thomas',
        relationship: AssociationRelationship.guardian,
        consentStatus: ConsentStatus.granted,
        consentDate: joinedAt,
        consentMethod: 'email confirmation',
        createdAt: joinedAt,
        lastModifiedAt: joinedAt,
      ),
    ];
  }

  @override
  Future<List<ReminderGroup>> fetchReminders() async {
    return const [
      ReminderGroup(
        title: 'Field Guide',
        reminders: [
          ReminderSetting(id: 'daily-reading', label: 'Daily Reading', timeLabel: '7:00 AM', enabled: true),
          ReminderSetting(id: 'evening-seal', label: 'Evening Seal', timeLabel: '9:00 PM', enabled: false),
        ],
      ),
      ReminderGroup(
        title: 'Weekly Challenges',
        reminders: [
          ReminderSetting(
            id: 'introduction',
            label: 'Introduction',
            timeLabel: 'Wednesdays at 7AM',
            enabled: true,
          ),
          ReminderSetting(id: 'last-chance', label: 'Last Chance', timeLabel: 'Mondays at 6PM', enabled: true),
        ],
      ),
      ReminderGroup(
        title: 'Events',
        reminders: [
          ReminderSetting(
            id: 'start-of-event',
            label: 'Start of Event',
            timeLabel: '30 minutes before',
            enabled: true,
          ),
        ],
      ),
    ];
  }
}
