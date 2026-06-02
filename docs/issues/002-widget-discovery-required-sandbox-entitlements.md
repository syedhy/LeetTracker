# Issue 002: Widget extension did not appear in macOS widget gallery

Status: Resolved

## Problem

The app built and launched, and the widget extension was embedded in the app bundle, but macOS did not list `LeetTracker` in the desktop widget gallery.

## Evidence

`pluginkit` did not initially list:

```text
com.hyder.LeetTracker.LeetTrackerWidgetExtension
```

The extension bundle existed and had the WidgetKit extension point, so the failure was in system discovery/registration rather than Swift compilation.

## Resolution

Added App Sandbox entitlements to both the app and the widget extension:

```text
com.apple.security.app-sandbox = true
```

After rebuilding and re-registering, `pluginkit` listed the WidgetKit extension successfully.
