# Issue 004: App Groups needed real Apple Development signing

Status: Resolved

GitHub Issue: #4

## What happened

After adding App Groups, the project stopped building with local ad-hoc signing. That makes sense: App Groups are a real entitlement, so Xcode needs an Apple Development identity and provisioning profile.

## What I saw before fixing it

At first, the machine had no signing identity:

```text
0 valid identities found
```

Normal build error:

```text
"LeetTracker" has entitlements that require signing with a development certificate.
"LeetTrackerWidgetExtension" has entitlements that require signing with a development certificate.
```

## Fix

Added the Apple account in Xcode and selected the development team for both targets.

Now `security find-identity -v -p codesigning` shows an Apple Development identity, and this normal signed build works:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project LeetTracker.xcodeproj -scheme LeetTracker -destination 'platform=macOS' build
```
