/// Per-environment config, supplied via `--dart-define-from-file` (see
/// env/*.example.json). The Supabase anon key is meant to be public — row
/// level security is the real authorization boundary — so this is about
/// switching between local/hosted projects, not secrecy. The service_role
/// key must never appear here or anywhere in this app.
class Env {
  const Env._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}
