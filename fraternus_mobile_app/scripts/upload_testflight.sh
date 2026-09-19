#!/usr/bin/env bash
# Builds a release IPA and uploads it to App Store Connect (TestFlight) via
# altool, authenticating with an App Store Connect API key.
#
# The Key ID / Issuer ID in env/testflight.json are just identifiers, not the
# secret — the actual credential is the .p8 private key, which must already
# be at ~/.appstoreconnect/private_keys/AuthKey_<API_KEY_ID>.p8 (altool finds
# it there by filename convention). That file is never checked into the repo;
# generate it at appstoreconnect.apple.com under Users and Access >
# Integrations if you don't have it.
set -euo pipefail

app_dir="$(cd "$(dirname "$0")/.." && pwd)"
cd "$app_dir"

config="env/testflight.json"
if [ ! -f "$config" ]; then
  echo "Missing $config — copy env/testflight.example.json and fill in your" \
    "App Store Connect API Key ID / Issuer ID." >&2
  exit 1
fi

api_key_id="$(jq -r '.API_KEY_ID' "$config")"
api_issuer_id="$(jq -r '.API_ISSUER_ID' "$config")"

private_key="$HOME/.appstoreconnect/private_keys/AuthKey_${api_key_id}.p8"
if [ ! -f "$private_key" ]; then
  echo "Missing App Store Connect API private key at $private_key" >&2
  echo "Generate one at appstoreconnect.apple.com (Users and Access >" \
    "Integrations), download the .p8, and save it there." >&2
  exit 1
fi

echo "Building release IPA..."
flutter build ipa --dart-define-from-file=env/prod.json

ipa="$(find build/ios/ipa -maxdepth 1 -name '*.ipa' | head -n1)"
if [ -z "$ipa" ]; then
  echo "No .ipa found in build/ios/ipa after build" >&2
  exit 1
fi

echo "Uploading $ipa to App Store Connect..."
xcrun altool --upload-app \
  --type ios \
  -f "$ipa" \
  --apiKey "$api_key_id" \
  --apiIssuer "$api_issuer_id"
