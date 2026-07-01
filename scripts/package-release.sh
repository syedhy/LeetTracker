#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCHEME="${SCHEME:-LeetTracker}"
CONFIGURATION="${CONFIGURATION:-Release}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$ROOT_DIR/build}"
DIST_DIR="${DIST_DIR:-$ROOT_DIR/dist}"
PUBLIC_RELEASE="${PUBLIC_RELEASE:-0}"
NOTARIZE="${NOTARIZE:-$PUBLIC_RELEASE}"
NOTARY_KEYCHAIN_PROFILE="${NOTARY_KEYCHAIN_PROFILE:-}"
APPLE_ID="${APPLE_ID:-}"
APPLE_TEAM_ID="${APPLE_TEAM_ID:-}"
APPLE_APP_SPECIFIC_PASSWORD="${APPLE_APP_SPECIFIC_PASSWORD:-}"
VERSION="${VERSION:-$(awk -F'= ' '/MARKETING_VERSION = / { gsub(/;/, "", $2); print $2; exit }' "$ROOT_DIR/LeetTracker.xcodeproj/project.pbxproj")}"
VERSION="${VERSION:-1.0}"
PACKAGE_NAME="${PACKAGE_NAME:-LeetTracker-$VERSION-macOS}"
PACKAGE_DIR="$DIST_DIR/$PACKAGE_NAME"
ZIP_PATH="$DIST_DIR/$PACKAGE_NAME.zip"
SHA_PATH="$ZIP_PATH.sha256"
APP_SOURCE="$DERIVED_DATA_PATH/Build/Products/$CONFIGURATION/LeetTracker.app"

if [[ "$PUBLIC_RELEASE" == "1" && "$NOTARIZE" != "1" ]]; then
  echo "PUBLIC_RELEASE=1 requires notarization. Do not disable NOTARIZE for public builds." >&2
  exit 1
fi

notarize_app() {
  local app_path="$1"
  local notary_zip="$DIST_DIR/$PACKAGE_NAME-notary.zip"

  echo "Preparing notarization archive..."
  rm -f "$notary_zip"
  (
    cd "$(dirname "$app_path")"
    ditto -c -k --norsrc --keepParent "$(basename "$app_path")" "$notary_zip"
  )

  echo "Submitting app for notarization..."
  if [[ -n "$NOTARY_KEYCHAIN_PROFILE" ]]; then
    xcrun notarytool submit "$notary_zip" --keychain-profile "$NOTARY_KEYCHAIN_PROFILE" --wait
  elif [[ -n "$APPLE_ID" && -n "$APPLE_TEAM_ID" && -n "$APPLE_APP_SPECIFIC_PASSWORD" ]]; then
    xcrun notarytool submit "$notary_zip" \
      --apple-id "$APPLE_ID" \
      --team-id "$APPLE_TEAM_ID" \
      --password "$APPLE_APP_SPECIFIC_PASSWORD" \
      --wait
  else
    echo "Notarization requested, but notarization credentials are missing." >&2
    echo "Set NOTARY_KEYCHAIN_PROFILE, or set APPLE_ID, APPLE_TEAM_ID, and APPLE_APP_SPECIFIC_PASSWORD." >&2
    exit 1
  fi

  echo "Stapling notarization ticket..."
  xcrun stapler staple "$app_path"
  xcrun stapler validate "$app_path"
  rm -f "$notary_zip"
}

echo "Building $SCHEME ($CONFIGURATION)..."
xcodebuild \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  CODE_SIGN_STYLE=Automatic \
  build

if [[ ! -d "$APP_SOURCE" ]]; then
  echo "Built app not found at: $APP_SOURCE" >&2
  exit 1
fi

SIGNING_INFO="$(codesign -dv --verbose=4 "$APP_SOURCE" 2>&1 || true)"

if [[ "$PUBLIC_RELEASE" == "1" ]] && ! grep -q "Authority=Developer ID Application" <<<"$SIGNING_INFO"; then
  echo "Public releases must be signed with a Developer ID Application certificate." >&2
  echo "Current signing info:" >&2
  echo "$SIGNING_INFO" >&2
  exit 1
fi

echo "Preparing release folder..."
rm -rf "$PACKAGE_DIR" "$ZIP_PATH" "$SHA_PATH"
mkdir -p "$PACKAGE_DIR"

ditto --rsrc --extattr "$APP_SOURCE" "$PACKAGE_DIR/LeetTracker.app"

if [[ "$NOTARIZE" == "1" ]]; then
  notarize_app "$PACKAGE_DIR/LeetTracker.app"
fi

echo "Creating $ZIP_PATH..."
(
  cd "$PACKAGE_DIR"
  ditto -c -k --keepParent "LeetTracker.app" "$ZIP_PATH"
)

shasum -a 256 "$ZIP_PATH" > "$SHA_PATH"

echo "Release package ready:"
echo "$ZIP_PATH"
echo "$SHA_PATH"

if [[ "$PUBLIC_RELEASE" != "1" ]]; then
  echo ""
  echo "Note: this package may be development-signed. Use PUBLIC_RELEASE=1 with a Developer ID signed build before publishing."
fi
