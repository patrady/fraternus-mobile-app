import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/profile/models/reminder_setting.dart';

void main() {
  group('ReminderType toJson/fromJson', () {
    test('every value round-trips through its db string', () {
      for (final type in ReminderType.values) {
        expect(ReminderType.fromJson(type.toJson()), type);
      }
    });

    test('an unrecognized db value throws rather than silently defaulting', () {
      expect(() => ReminderType.fromJson('not_a_type'), throwsArgumentError);
    });
  });

  group('ReminderSetting', () {
    test('id mirrors the type name', () {
      const setting = ReminderSetting(type: ReminderType.fieldGuideMorning, enabled: true);
      expect(setting.id, 'fieldGuideMorning');
      expect(setting.label, ReminderType.fieldGuideMorning.label);
    });

    test('copyWith only changes enabled', () {
      const setting = ReminderSetting(type: ReminderType.fieldGuideMorning, enabled: true);
      final copy = setting.copyWith(enabled: false);

      expect(copy.enabled, isFalse);
      expect(copy.type, setting.type);
    });
  });

  group('ReminderGroup.groupedTypes', () {
    test('covers every ReminderType exactly once across all groups', () {
      final grouped = ReminderGroup.groupedTypes.values.expand((types) => types).toList();

      expect(grouped.toSet(), ReminderType.values.toSet());
      expect(grouped, hasLength(ReminderType.values.length));
    });
  });
}
