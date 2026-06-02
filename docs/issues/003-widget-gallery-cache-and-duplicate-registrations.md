# Issue 003: Widget gallery got stuck with stale registrations

Status: Resolved

GitHub Issue: #3

## What happened

`pluginkit` was finally seeing the widget, but the widget gallery still did not show `LeetTracker` in search.

## What probably caused it

During debugging I had a few app bundles with the same bundle IDs:

```text
/Applications/LeetTracker.app
/Applications/LeetTrackerRelease.app
/Applications/LeetTrackerSandbox.app
DerivedData Debug and Release builds
```

That seems to have confused WidgetKit/Notification Center.

## What fixed it

- Unregistered duplicate extension paths with `pluginkit -r`.
- Added App Sandbox entitlements.
- Changed the widget kind to a reverse-DNS identifier.
- Reload widget timelines when the host app launches.
- Restarted Notification Center and `chronod`.

After that, the widget appeared on the desktop and rendered `LeetTracker / Widget ready`.

## Follow-Up

The temporary `/Applications/LeetTracker*.app` copies are still on disk, but they are no longer registered as WidgetKit providers. I will leave them alone unless they cause trouble again.
