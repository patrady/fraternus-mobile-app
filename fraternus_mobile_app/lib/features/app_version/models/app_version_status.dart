/// Result of the boot-time check against `get_app_version_status` — see
/// supabase/migrations/20260905000000_app_version_lockout.sql.
class AppVersionStatus {
  const AppVersionStatus({required this.blocked, this.reason, this.message});

  /// Used when the check hasn't run yet, or failed and fell open (offline,
  /// Supabase outage, timeout) — see resolveAppVersionStatus.
  const AppVersionStatus.notBlocked() : this(blocked: false);

  factory AppVersionStatus.fromJson(Map<String, dynamic> json) {
    return AppVersionStatus(
      blocked: json['blocked'] as bool? ?? false,
      reason: json['reason'] as String?,
      message: json['message'] as String?,
    );
  }

  final bool blocked;

  /// 'deprecated' (this exact version was denylisted) or 'below_minimum'
  /// (below the platform's floor) — null when not blocked.
  final String? reason;

  /// Admin-supplied copy to show on the update-required screen, if any.
  final String? message;
}
