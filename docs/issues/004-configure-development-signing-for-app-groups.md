# Issue 004: Configure Apple Development signing for App Groups

Status: Open

GitHub Issue: #4

## Problem

Phase 3 adds App Group entitlements so the macOS app and WidgetKit extension can share username and cached stats. Xcode can compile the project with signing disabled, but a normal signed build currently fails because no valid Apple Development code-signing identity is installed.

## Evidence

`security find-identity -v -p codesigning` reports:

```text
0 valid identities found
```

Normal build error:

```text
"LeetTracker" has entitlements that require signing with a development certificate.
"LeetTrackerWidgetExtension" has entitlements that require signing with a development certificate.
```

## Current Workaround

Use this command to compile the Phase 3 code without signing:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project LeetTracker.xcodeproj -scheme LeetTracker -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build
```

## Resolution Path

1. Open Xcode settings.
2. Add an Apple ID under Accounts if one is not already present.
3. Select the `LeetTracker` project.
4. For both targets, select a development team under Signing & Capabilities.
5. Ensure the App Group `group.com.hyder.LeetTracker` is available for both targets.
6. Re-run a normal build without `CODE_SIGNING_ALLOWED=NO`.
