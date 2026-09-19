#!/usr/bin/env bash
# Runs the app against the local Supabase stack, forwarding any extra flags
# (e.g. -d ios, -d android) straight to `flutter run` — this exists because
# `flutter run` alone silently leaves Env.supabaseUrl/supabaseAnonKey empty,
# which fails with no useful error message (see sign-up OTP debugging).
#
# Also self-heals a local-only Supabase CLI quirk: Kong only registers the
# route that serves our custom auth email templates
# (supabase/templates/*.html) on a genuine cold `supabase start`. If the
# stack has been left running across a reboot/sleep, a later `supabase
# start` just prints status without re-registering that route — Kong then
# silently 404s on it and GoTrue falls back to Supabase's stock link-only
# email instead of the 6-digit code the signup flow expects, with no error
# anywhere. See supabase/config.toml's [auth.email.template.*] comments
# for the template half of this.
set -euo pipefail

app_dir="$(cd "$(dirname "$0")/.." && pwd)"
repo_root="$(cd "$app_dir/.." && pwd)"

api_url="http://127.0.0.1:54321"
mailpit_url="http://127.0.0.1:54324"

anon_key() {
  (cd "$repo_root" && supabase status -o json 2>/dev/null) | jq -r '.ANON_KEY // empty'
}

# Sends a throwaway signup OTP and checks whether the email that actually
# went out used our custom code template (vs. the stock magic-link
# fallback) — a live, black-box check of what a real signup would get,
# rather than trusting container/route state.
email_templates_ok() {
  local key="$1"
  local probe_email="supabase-template-healthcheck-$$@example.com"

  curl -fsS -X POST "$api_url/auth/v1/otp" \
    -H "apikey: $key" -H "Content-Type: application/json" \
    -d "{\"email\":\"$probe_email\",\"create_user\":true}" >/dev/null 2>&1 || return 1

  sleep 1

  curl -fsS "$mailpit_url/api/v1/search?query=to:$probe_email&limit=1" 2>/dev/null \
    | jq -e '.messages[0].Subject == "Your Fraternus verification code"' >/dev/null 2>&1
}

cd "$repo_root"

if ! key="$(anon_key)" || [ -z "$key" ]; then
  echo "Local Supabase stack isn't running — starting it..."
  supabase start
  key="$(anon_key)"
elif ! email_templates_ok "$key"; then
  echo "Local Supabase auth emails are falling back to the stock magic-link template" \
    "(a known drift after the stack's been left running across a reboot) —" \
    "recreating the stack to fix it..."
  supabase stop
  supabase start
  key="$(anon_key)"
  if ! email_templates_ok "$key"; then
    echo "Still not sending the code template after a clean restart — needs manual" \
      "investigation (see supabase/config.toml's [auth.email.template.*] comments)." >&2
    exit 1
  fi
  echo "Fixed — local signup emails will include the 6-digit code again."
fi

cd "$app_dir"
exec flutter run --dart-define-from-file=env/local.json "$@"
