# Issue 002: Widget was not showing up in the widget gallery

Status: Resolved

GitHub Issue: #2

## What happened

The app built and ran, and the widget extension was inside the app bundle, but macOS still did not show `LeetTracker` in the desktop widget gallery.

## What I checked

`pluginkit` did not initially list:

```text
com.hyder.LeetTracker.LeetTrackerWidgetExtension
```

So the Swift code was not the problem. The system just was not registering the extension.

## Fix

Added App Sandbox entitlements to both targets:

```text
com.apple.security.app-sandbox = true
```

After rebuilding, macOS started registering the WidgetKit extension.
