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
mkdir -p "$PACKAGE_DIR/Tools"

ditto --rsrc --extattr "$APP_SOURCE" "$PACKAGE_DIR/LeetTracker.app"

if [[ "$NOTARIZE" == "1" ]]; then
  notarize_app "$PACKAGE_DIR/LeetTracker.app"
fi

cp "$ROOT_DIR/scripts/install-background-refresh-agent.sh" "$PACKAGE_DIR/Tools/install-background-refresh-agent.sh"
cp "$ROOT_DIR/scripts/uninstall-background-refresh-agent.sh" "$PACKAGE_DIR/Tools/uninstall-background-refresh-agent.sh"
cp "$ROOT_DIR/README.md" "$PACKAGE_DIR/README.md"
[[ -f "$ROOT_DIR/docs/privacy.md" ]] && cp "$ROOT_DIR/docs/privacy.md" "$PACKAGE_DIR/PRIVACY.md"
chmod +x "$PACKAGE_DIR/Tools/"*.sh

cat > "$PACKAGE_DIR/Install Background Refresh.command" <<'COMMAND'
#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_PATH="/Applications/LeetTracker.app" "$SCRIPT_DIR/Tools/install-background-refresh-agent.sh"

echo ""
echo "LeetTracker background refresh is installed."
echo "You can close this window."
read -k 1 "?Press any key to close..."
COMMAND

cat > "$PACKAGE_DIR/Uninstall Background Refresh.command" <<'COMMAND'
#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"$SCRIPT_DIR/Tools/uninstall-background-refresh-agent.sh"

echo ""
echo "LeetTracker background refresh is removed."
echo "You can close this window."
read -k 1 "?Press any key to close..."
COMMAND

chmod +x "$PACKAGE_DIR/"*.command

cat > "$PACKAGE_DIR/README_INSTALL.txt" <<'README'
LeetTracker for macOS

Install:
1. Move LeetTracker.app to your Applications folder.
2. Open LeetTracker.app once.
3. Enter your LeetCode username and press Refresh.
4. Add the LeetTracker widget from macOS Edit Widgets.

Background widget refresh:
- Double-click "Install Background Refresh.command" after moving the app to Applications.
- This lets the widget refresh every 2 hours while the app window is closed.
- Double-click "Uninstall Background Refresh.command" to remove the helper.
- Homebrew users can run leettracker-install-background-refresh instead.

If macOS blocks the app:
Open System Settings > Privacy & Security and allow LeetTracker.

Data:
- LeetTracker uses public LeetCode solved counts only.
- Do not use LeetTracker to monitor accounts you do not own or have permission to track.
- LeetTracker does not ask for LeetCode credentials or private cookies.

LeetTracker is independent and is not affiliated with LeetCode.
README

echo "Creating $ZIP_PATH..."
(
  cd "$DIST_DIR"
  ditto -c -k --norsrc --keepParent "$PACKAGE_NAME" "$ZIP_PATH"
)

shasum -a 256 "$ZIP_PATH" > "$SHA_PATH"

echo "Release package ready:"
echo "$ZIP_PATH"
echo "$SHA_PATH"

if [[ "$PUBLIC_RELEASE" != "1" ]]; then
  echo ""
  echo "Note: this package may be development-signed. Use PUBLIC_RELEASE=1 with a Developer ID signed build before publishing."
fi
