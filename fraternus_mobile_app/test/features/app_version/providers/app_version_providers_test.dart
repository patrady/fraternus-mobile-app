import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/app_version/data/app_version_repository.dart';
import 'package:fraternus_mobile_app/features/app_version/models/app_version_status.dart';
import 'package:fraternus_mobile_app/features/app_version/providers/app_version_providers.dart';
import 'package:package_info_plus/package_info_plus.dart';

class _FakeAppVersionRepository implements AppVersionRepository {
  _FakeAppVersionRepository({this.result, this.error, this.delay});

  final AppVersionStatus? result;
  final Object? error;
  final Duration? delay;

  String? requestedPlatform;
  String? requestedVersion;

  @override
  Future<AppVersionStatus> checkStatus({
    required String platform,
    required String version,
  }) async {
    requestedPlatform = platform;
    requestedVersion = version;
    if (delay != null) await Future<void>.delayed(delay!);
    if (error != null) throw error!;
    return result ?? const AppVersionStatus.notBlocked();
  }
}

void main() {
  setUp(() {
    // Avoids a MissingPluginException — PackageInfo.fromPlatform() would
    // otherwise reach for a real platform channel that doesn't exist in
    // the test environment.
    PackageInfo.setMockInitialValues(
      appName: 'Fraternus',
      packageName: 'com.example.fraternus_mobile_app',
      version: '1.2.0',
      buildNumber: '5',
      buildSignature: '',
    );
  });

  test(
    'passes the marketing version (not the build number) to the repository',
    () async {
      final repository = _FakeAppVersionRepository();

      await resolveAppVersionStatus(repository);

      expect(repository.requestedVersion, '1.2.0');
      expect(repository.requestedPlatform, anyOf('ios', 'android'));
    },
  );

  test('returns the repository result when the check succeeds', () async {
    const blocked = AppVersionStatus(
      blocked: true,
      reason: 'deprecated',
      message: 'Update, please.',
    );
    final repository = _FakeAppVersionRepository(result: blocked);

    final status = await resolveAppVersionStatus(repository);

    expect(status.blocked, isTrue);
    expect(status.reason, 'deprecated');
    expect(status.message, 'Update, please.');
  });

  test('fails open (not blocked) when the repository throws', () async {
    final repository = _FakeAppVersionRepository(error: Exception('offline'));

    final status = await resolveAppVersionStatus(repository);

    expect(status.blocked, isFalse);
  });

  test('fails open when the check exceeds the timeout, even if it would '
      'have come back blocked', () async {
    final repository = _FakeAppVersionRepository(
      delay: const Duration(milliseconds: 50),
      result: const AppVersionStatus(blocked: true, reason: 'deprecated'),
    );

    final status = await resolveAppVersionStatus(
      repository,
      timeout: const Duration(milliseconds: 5),
    );

    expect(status.blocked, isFalse);
  });
}
