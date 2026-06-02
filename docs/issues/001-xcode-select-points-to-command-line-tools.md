# Issue 001: Terminal xcodebuild uses Command Line Tools by default

Status: Open

## Problem

Running `xcodebuild` directly fails because `xcode-select` currently points to:

```text
/Library/Developer/CommandLineTools
```

That developer directory cannot build native Xcode app projects with WidgetKit targets.

## Current Workaround

Use full Xcode explicitly:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project LeetTracker.xcodeproj -scheme LeetTracker -destination 'platform=macOS' build
```

## Possible Resolution

Switch the active developer directory to full Xcode:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

Only do this if you want Terminal tools globally pointed at Xcode instead of Command Line Tools.
