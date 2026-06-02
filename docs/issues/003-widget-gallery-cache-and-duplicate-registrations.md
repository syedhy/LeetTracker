# Issue 003: Widget gallery cache still does not show LeetTracker

Status: Open

## Problem

`pluginkit` can register `com.hyder.LeetTracker.LeetTrackerWidgetExtension`, but the macOS desktop widget gallery still does not show `LeetTracker` in search.

## Evidence

The system has seen multiple app bundles with the same app and extension identifiers during debugging:

```text
/Applications/LeetTracker.app
/Applications/LeetTrackerRelease.app
/Applications/LeetTrackerSandbox.app
DerivedData Debug and Release builds
```

Duplicate registrations with the same widget extension identifier can leave WidgetKit/Notification Center in a confusing state.

## Current Mitigation

- Unregistered duplicate extension paths with `pluginkit -r`.
- Added App Sandbox entitlements.
- Changed the widget kind to a reverse-DNS identifier.
- Reload widget timelines when the host app launches.

## Next Steps

Move the temporary `/Applications/LeetTracker*.app` test copies to Trash, clear the widget daemon cache, rebuild, and register exactly one app bundle.
