#!/bin/zsh
set -euo pipefail

LABEL="com.hyder.LeetTracker.background-refresh"
APP_PATH="${APP_PATH:-/Applications/LeetTracker.app}"
INTERVAL_SECONDS="${INTERVAL_SECONDS:-7200}"
PLIST_PATH="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG_DIR="$HOME/Library/Logs/LeetTracker"
EXECUTABLE_PATH="$APP_PATH/Contents/MacOS/LeetTracker"

if [[ ! -x "$EXECUTABLE_PATH" ]]; then
  echo "LeetTracker executable not found at: $EXECUTABLE_PATH" >&2
  exit 1
fi

mkdir -p "$HOME/Library/LaunchAgents" "$LOG_DIR"

cat > "$PLIST_PATH" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>$EXECUTABLE_PATH</string>
    <string>--background-refresh</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>StartInterval</key>
  <integer>$INTERVAL_SECONDS</integer>
  <key>StandardOutPath</key>
  <string>$LOG_DIR/background-refresh.log</string>
  <key>StandardErrorPath</key>
  <string>$LOG_DIR/background-refresh.log</string>
</dict>
</plist>
PLIST

chmod 644 "$PLIST_PATH"
plutil -lint "$PLIST_PATH" >/dev/null

launchctl bootout "gui/$(id -u)" "$PLIST_PATH" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$(id -u)" "$PLIST_PATH"
launchctl kickstart -k "gui/$(id -u)/$LABEL"

echo "Installed LeetTracker background refresh agent."
echo "Label: $LABEL"
echo "Interval: ${INTERVAL_SECONDS}s"
echo "Log: $LOG_DIR/background-refresh.log"
