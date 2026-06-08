#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="${DIST_DIR:-$ROOT_DIR/dist}"
VERSION="${VERSION:-$(awk -F'= ' '/MARKETING_VERSION = / { gsub(/;/, "", $2); print $2; exit }' "$ROOT_DIR/LeetTracker.xcodeproj/project.pbxproj")}"
VERSION="${VERSION:-1.0}"
PACKAGE_NAME="${PACKAGE_NAME:-LeetTracker-$VERSION-macOS}"
ZIP_PATH="${ZIP_PATH:-$DIST_DIR/$PACKAGE_NAME.zip}"
SHA_PATH="$ZIP_PATH.sha256"
APP_PATH="$DIST_DIR/$PACKAGE_NAME/LeetTracker.app"

if [[ ! -f "$ZIP_PATH" ]]; then
  echo "Missing release zip: $ZIP_PATH" >&2
  exit 1
fi

if [[ ! -f "$SHA_PATH" ]]; then
  echo "Missing checksum file: $SHA_PATH" >&2
  exit 1
fi

echo "Checking checksum..."
EXPECTED_SHA="$(awk '{print $1}' "$SHA_PATH")"
ACTUAL_SHA="$(shasum -a 256 "$ZIP_PATH" | awk '{print $1}')"

if [[ "$EXPECTED_SHA" != "$ACTUAL_SHA" ]]; then
  echo "Checksum mismatch." >&2
  echo "Expected: $EXPECTED_SHA" >&2
  echo "Actual:   $ACTUAL_SHA" >&2
  exit 1
fi

echo "Checking zip layout..."
zipinfo -1 "$ZIP_PATH" | grep -q "^$PACKAGE_NAME/LeetTracker.app/Contents/Info.plist$"

if [[ -d "$APP_PATH" ]]; then
  echo "Checking code signature..."
  codesign --verify --deep --strict --verbose=2 "$APP_PATH"

  echo "Checking Gatekeeper assessment..."
  if ! spctl -a -vv -t install "$APP_PATH"; then
    echo ""
    echo "Gatekeeper rejected this app. For public distribution, sign with Developer ID and notarize/staple the app before release." >&2
    exit 1
  fi
else
  echo "Expanded app not found at $APP_PATH; unzip the package first for signature checks."
fi

echo "Release package checks passed."
