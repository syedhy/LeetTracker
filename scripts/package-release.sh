#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCHEME="${SCHEME:-LeetTracker}"
CONFIGURATION="${CONFIGURATION:-Release}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$ROOT_DIR/build}"
DIST_DIR="${DIST_DIR:-$ROOT_DIR/dist}"
PACKAGE_NAME="${PACKAGE_NAME:-LeetTracker-macOS}"
PACKAGE_DIR="$DIST_DIR/$PACKAGE_NAME"
ZIP_PATH="$DIST_DIR/$PACKAGE_NAME.zip"
APP_SOURCE="$DERIVED_DATA_PATH/Build/Products/$CONFIGURATION/LeetTracker.app"

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

echo "Preparing release folder..."
rm -rf "$PACKAGE_DIR" "$ZIP_PATH"
mkdir -p "$PACKAGE_DIR/Tools"

ditto --rsrc --extattr "$APP_SOURCE" "$PACKAGE_DIR/LeetTracker.app"
cp "$ROOT_DIR/scripts/install-background-refresh-agent.sh" "$PACKAGE_DIR/Tools/install-background-refresh-agent.sh"
cp "$ROOT_DIR/scripts/uninstall-background-refresh-agent.sh" "$PACKAGE_DIR/Tools/uninstall-background-refresh-agent.sh"
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
- This lets the widget refresh while the app window is closed.
- Double-click "Uninstall Background Refresh.command" to remove the helper.

If macOS blocks the app:
Open System Settings > Privacy & Security and allow LeetTracker.

LeetTracker is independent and is not affiliated with LeetCode.
README

echo "Creating $ZIP_PATH..."
(
  cd "$DIST_DIR"
  ditto -c -k --norsrc --keepParent "$PACKAGE_NAME" "$ZIP_PATH"
)

echo "Release package ready:"
echo "$ZIP_PATH"
