# Issue 003: Widget gallery cache did not show LeetTracker

Status: Resolved

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
- Restarted Notification Center and `chronod`.

## Resolution

After clearing stale LeetTracker widget registrations and restarting widget services, the widget appeared on the desktop and rendered the placeholder `LeetTracker / Widget ready` content.

## Follow-Up

An attempt was made to move the temporary `/Applications/LeetTracker*.app` test copies to Trash with Finder automation, but macOS left them in place. They are no longer registered as WidgetKit providers. Leave them alone unless they cause a future conflict, or remove them manually from Finder.
