#!/usr/bin/env bash
# Runs the app against the local Supabase stack, forwarding any extra flags
# (e.g. -d ios, -d android) straight to `flutter run` — this exists because
# `flutter run` alone silently leaves Env.supabaseUrl/supabaseAnonKey empty,
# which fails with no useful error message (see sign-up OTP debugging).
set -euo pipefail
cd "$(dirname "$0")/.."
exec flutter run --dart-define-from-file=env/local.json "$@"
