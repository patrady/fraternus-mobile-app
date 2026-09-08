import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/supabase_provider.dart';
import '../data/app_version_repository.dart';
import '../models/app_version_status.dart';

part 'app_version_providers.g.dart';

/// Swap this provider's implementation to change where the version-lockout
/// check's data comes from — nothing downstream needs to change.
@riverpod
AppVersionRepository appVersionRepository(Ref ref) {
  return SupabaseAppVersionRepository(ref.watch(supabaseClientProvider));
}

/// The boot-time check's result, resolved once in `main.dart` (via
/// [resolveAppVersionStatus]) before `runApp` and injected with
/// `.overrideWithValue` — mirrors sharedPreferencesProvider. The router's
/// `redirect` can't itself `await`, so this needs to already be resolved
/// and readable synchronously (`ref.read`) by the time it first runs.
@riverpod
AppVersionStatus appVersionStatus(Ref ref) {
  throw UnimplementedError(
    'appVersionStatusProvider must be overridden — see main.dart',
  );
}

/// Runs the boot-time check with a bounded timeout, failing open (treating
/// it as "not blocked") on any error — offline, a Supabase outage, a slow
/// response — so a network hiccup can never brick the app for everyone.
/// Kept as a plain function rather than a provider: it has to run and
/// resolve in `main()`, before the `ProviderScope` (and so before
/// [appVersionRepositoryProvider]) exists. [timeout] is overridable so
/// tests can exercise the timeout path without a real multi-second wait.
Future<AppVersionStatus> resolveAppVersionStatus(
  AppVersionRepository repository, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    final platform = defaultTargetPlatform == TargetPlatform.iOS
        ? 'ios'
        : 'android';
    return await repository
        .checkStatus(platform: platform, version: packageInfo.version)
        .timeout(timeout);
  } catch (error) {
    debugPrint('App version check failed, continuing anyways: (Error: $error)');
    return const AppVersionStatus.notBlocked();
  }
}
