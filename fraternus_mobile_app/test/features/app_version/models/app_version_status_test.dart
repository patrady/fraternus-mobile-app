import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/app_version/models/app_version_status.dart';

void main() {
  group('AppVersionStatus.notBlocked', () {
    test('has no reason or message', () {
      const status = AppVersionStatus.notBlocked();

      expect(status.blocked, isFalse);
      expect(status.reason, isNull);
      expect(status.message, isNull);
    });
  });

  group('AppVersionStatus.fromRpcResult', () {
    test('parses a blocked/deprecated result', () {
      final status = AppVersionStatus.fromJson({
        'blocked': true,
        'reason': 'deprecated',
        'message': 'This version has a critical bug, please update.',
      });

      expect(status.blocked, isTrue);
      expect(status.reason, 'deprecated');
      expect(status.message, 'This version has a critical bug, please update.');
    });

    test('parses a blocked/below_minimum result', () {
      final status = AppVersionStatus.fromJson({
        'blocked': true,
        'reason': 'below_minimum',
        'message': null,
      });

      expect(status.blocked, isTrue);
      expect(status.reason, 'below_minimum');
      expect(status.message, isNull);
    });

    test('parses a not-blocked result', () {
      final status = AppVersionStatus.fromJson({'blocked': false});

      expect(status.blocked, isFalse);
      expect(status.reason, isNull);
      expect(status.message, isNull);
    });

    test('defaults to not blocked when the blocked field is missing', () {
      final status = AppVersionStatus.fromJson({});

      expect(status.blocked, isFalse);
    });
  });
}
