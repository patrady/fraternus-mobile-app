/// Per-environment config, supplied via `--dart-define-from-file` (see
/// env/*.example.json). The Supabase anon key is meant to be public — row
/// level security is the real authorization boundary — so this is about
/// switching between local/hosted projects, not secrecy. The service_role
/// key must never appear here or anywhere in this app.
class Env {
  const Env._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Store listing identifiers for UpdateRequiredScreen's "Update Now"
  /// button — not secrets, just kept out of source since they're the kind
  /// of thing that changes without a code change once the app is
  /// published. Empty by default (e.g. in `flutter test`, or before the
  /// app has a real store listing); UpdateRequiredScreen only renders the
  /// button once these are non-empty.
  static const storeAndroidPackageId = String.fromEnvironment(
    'STORE_ANDROID_PACKAGE_ID',
  );
  static const storeIosAppId = String.fromEnvironment('STORE_IOS_APP_ID');
}
