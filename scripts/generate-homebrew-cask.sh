#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="${DIST_DIR:-$ROOT_DIR/dist}"
VERSION="${VERSION:-$(awk -F'= ' '/MARKETING_VERSION = / { gsub(/;/, "", $2); print $2; exit }' "$ROOT_DIR/LeetTracker.xcodeproj/project.pbxproj")}"
VERSION="${VERSION:-1.0}"
REPO="${REPO:-syedhy/leettracker}"
PACKAGE_NAME="${PACKAGE_NAME:-LeetTracker-$VERSION-macOS}"
ZIP_PATH="${ZIP_PATH:-$DIST_DIR/$PACKAGE_NAME.zip}"
CASK_DIR="${CASK_DIR:-$ROOT_DIR/packaging/homebrew/Casks}"
CASK_PATH="$CASK_DIR/leettracker.rb"

if [[ ! -f "$ZIP_PATH" ]]; then
  echo "Release zip not found at: $ZIP_PATH" >&2
  echo "Run scripts/package-release.sh first." >&2
  exit 1
fi

SHA256="$(shasum -a 256 "$ZIP_PATH" | awk '{print $1}')"

mkdir -p "$CASK_DIR"

cat > "$CASK_PATH" <<CASK
cask "leettracker" do
  version "$VERSION"
  sha256 "$SHA256"

  url "https://github.com/$REPO/releases/download/v#{version}/LeetTracker-#{version}-macOS.zip"
  name "LeetTracker"
  desc "macOS app and widgets for public LeetCode progress"
  homepage "https://github.com/$REPO"

  depends_on macos: ">= :sonoma"

  app "LeetTracker-#{version}-macOS/LeetTracker.app"
  binary "LeetTracker-#{version}-macOS/Tools/install-background-refresh-agent.sh", target: "leettracker-install-background-refresh"
  binary "LeetTracker-#{version}-macOS/Tools/uninstall-background-refresh-agent.sh", target: "leettracker-uninstall-background-refresh"

  uninstall launchctl: "com.hyder.LeetTracker.background-refresh"

  zap trash: [
    "~/Library/Application Support/LeetTracker",
    "~/Library/Containers/com.hyder.LeetTracker",
    "~/Library/Containers/com.hyder.LeetTracker.LeetTrackerWidgetExtension",
    "~/Library/Group Containers/group.com.hyder.LeetTracker",
    "~/Library/LaunchAgents/com.hyder.LeetTracker.background-refresh.plist",
    "~/Library/Logs/LeetTracker",
  ]

  caveats <<~EOS
    Open LeetTracker once, enter your LeetCode username, then add widgets from macOS Edit Widgets.

    Optional background refresh:
      leettracker-install-background-refresh

    Remove background refresh:
      leettracker-uninstall-background-refresh
  EOS
end
CASK

echo "Homebrew cask written to:"
echo "$CASK_PATH"
