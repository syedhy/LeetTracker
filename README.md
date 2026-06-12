# LeetTracker

LeetTracker is a macOS app with desktop widgets for keeping your public LeetCode progress visible. Add your username once, then use the app for goals, reminders, analytics, and quick progress widgets.

LeetTracker does not ask for your LeetCode password.

Requires macOS 14 or newer.

## Install

### Recommended: Homebrew

```zsh
brew tap syedhy/leettracker
brew install --cask leettracker
```

Then:

1. Open LeetTracker.
2. Enter your LeetCode username.
3. Press **Refresh**.
4. Open macOS **Edit Widgets** and search for **LeetTracker**.
5. Add the widgets you want.

Optional background refresh:

```zsh
leettracker-install-background-refresh
```

This lets LeetTracker refresh widget data every 2 hours while the app window is closed. Remove it with:

```zsh
leettracker-uninstall-background-refresh
```

### Alternative: GitHub Release

1. Open the [latest release](https://github.com/syedhy/leettracker/releases/latest) on GitHub.
2. Download `LeetTracker-<version>-macOS.zip`.
3. Unzip it.
4. Move `LeetTracker.app` to your **Applications** folder.
5. Open LeetTracker and enter your LeetCode username.
6. Add widgets from macOS **Edit Widgets**.

The release zip also includes **Install Background Refresh.command**. Double-click it after moving the app to Applications if you want widget refresh while the app window is closed.

### Build From Source

Use this only if you are comfortable with Xcode.

```zsh
git clone https://github.com/syedhy/leettracker.git
cd LeetTracker
open LeetTracker.xcodeproj
```

In Xcode, select the `LeetTracker` scheme, choose **My Mac**, then build and run.

## What You Get

- Public LeetCode solved-count tracking
- Small and medium desktop widgets
- Goal setting with difficulty targets
- Practice reminders
- Dashboard and analytics views
- Background widget refresh support
- A focused macOS interface for LeetCode planning

## Privacy And Ethics

LeetTracker uses public LeetCode profile data only. It does not use passwords, private cookies, private submissions, or hidden profile data.

Use LeetTracker with your own username or with a username you have permission to track. Do not use it for scraping, bulk lookups, account enumeration, or competitive monitoring.

LeetTracker is independent and is not affiliated with, endorsed by, or sponsored by LeetCode.

See [docs/privacy.md](docs/privacy.md) for the full privacy summary.

## Troubleshooting

If the widget does not show up immediately, open LeetTracker once from Applications, press **Refresh**, then open macOS **Edit Widgets** again. macOS can take a short moment to register new widget extensions.

If macOS blocks the app after download, open **System Settings > Privacy & Security** and allow LeetTracker.

If the widget seems stale, press **Refresh** in the app once. The widget refreshes automatically after that, but macOS controls the exact timing.
