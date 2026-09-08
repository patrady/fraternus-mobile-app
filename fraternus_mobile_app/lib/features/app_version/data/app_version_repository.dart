import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_version_status.dart';

/// Source of the boot-time version-lockout check — same seam as every
/// other XRepository in this app.
abstract class AppVersionRepository {
  Future<AppVersionStatus> checkStatus({
    required String platform,
    required String version,
  });
}

/// Calls the SECURITY DEFINER `get_app_version_status` function (see
/// supabase/migrations/20260905000000_app_version_lockout.sql) rather than
/// reading the underlying tables directly — they're locked down and not
/// selectable by anon/authenticated.
class SupabaseAppVersionRepository implements AppVersionRepository {
  SupabaseAppVersionRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<AppVersionStatus> checkStatus({
    required String platform,
    required String version,
  }) async {
    final result = await _client.rpc(
      'get_app_version_status',
      params: {'p_platform': platform, 'p_version': version},
    );

    return AppVersionStatus.fromJson(result as Map<String, dynamic>);
  }
}
