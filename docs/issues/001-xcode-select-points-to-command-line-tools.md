# Issue 001: Terminal xcodebuild points at Command Line Tools

Status: Open

GitHub Issue: #1

## What happened

When I run `xcodebuild` directly, it uses:

```text
/Library/Developer/CommandLineTools
```

That is fine for basic command line stuff, but it is not enough for this Xcode app + WidgetKit project.

## What works for now

I can build by pointing the command at full Xcode:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project LeetTracker.xcodeproj -scheme LeetTracker -destination 'platform=macOS' build
```

## Fix when I want to

If I want Terminal to always use full Xcode, run:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

Leaving this open for now because the workaround is good enough.
