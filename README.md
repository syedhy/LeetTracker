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

4. Open LeetTracker and enter your LeetCode username.
5. Add widgets from macOS **Edit Widgets**.
6. (Optional) Go to Settings in LeetTracker to enable Background Refresh.

### Build From Source

Use this only if you are comfortable with Xcode.

```zsh
git clone https://github.com/syedhy/leettracker.git
cd LeetTracker
```

To build and package the DMG, run:
```zsh
./package_release.sh
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
