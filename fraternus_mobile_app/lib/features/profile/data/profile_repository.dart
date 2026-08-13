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

  @override
  Future<AppUser> fetchCurrentUser() async {
    return const AppUser(
      id: _userId,
      firstName: 'John',
      lastName: 'Smith',
      email: 'john.smith@example.com',
    );
  }

  @override
  Future<List<Member>> fetchMembers() async {
    final now = DateTime.now();
    return [
      const Member(
        id: 'you',
        firstName: 'John',
        lastName: 'Smith',
        role: MemberRole.captain,
        chapterId: 'st-philips-franklin',
      ),
      Member(
        id: 'jack',
        firstName: 'Jack',
        lastName: 'Smith',
        role: MemberRole.brother,
        chapterId: 'st-philips-franklin',
        birthday: DateTime(now.year - 12, 5, 12),
      ),
      Member(
        id: 'thomas',
        firstName: 'Thomas',
        lastName: 'Smith',
        role: MemberRole.brother,
        chapterId: 'st-philips-franklin',
        birthday: DateTime(now.year - 9, 9, 3),
      ),
    ];
  }

  @override
  Future<List<UserMemberAssociation>> fetchAssociations() async {
    return const [
      UserMemberAssociation(
        userId: _userId,
        memberId: 'you',
        relationship: AssociationRelationship.self,
      ),
      UserMemberAssociation(
        userId: _userId,
        memberId: 'jack',
        relationship: AssociationRelationship.guardian,
      ),
      UserMemberAssociation(
        userId: _userId,
        memberId: 'thomas',
        relationship: AssociationRelationship.guardian,
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
