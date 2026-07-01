# LeetTracker

LeetTracker is a macOS app with desktop widgets for keeping your public LeetCode progress visible. Add your username once, then use the app for goals, reminders, analytics, and quick progress widgets.

LeetTracker does not ask for your LeetCode password.

Requires macOS 14 or newer.

## Install

### FREE_UNSIGNED_RELEASE (Default)

LeetTracker is currently distributed as a `FREE_UNSIGNED_RELEASE`. Because the app is unsigned, macOS Gatekeeper may block it the first time. To bypass this:

1. Download and extract the app, then move **LeetTracker.app** to your **Applications** folder.
2. **Right-Click** on LeetTracker in Applications and select **Open**.
3. Click **Open** in the dialog box.
4. You only need to do this once. Future launches will work normally.

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

### Build From Source

Use this only if you are comfortable with Xcode.

```zsh
git clone https://github.com/syedhy/leettracker.git
cd LeetTracker
```

To build and package the release, run:
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

### Background Refresh

To keep your widgets up to date even when the app is closed, you can enable background refresh. Widgets update about every 2 hours, but macOS controls the exact timing.

**Recommended Method**
Open LeetTracker, go to **Settings**, and click **Enable Background Refresh**. This is the recommended and easiest method for most users.

**For Power Users**
If you prefer the terminal, you can manage the background LaunchAgent using the Homebrew commands:
```zsh
leettracker-install-background-refresh
leettracker-uninstall-background-refresh
```
Or by running the manual scripts from the source directory:
```zsh
./scripts/install-background-refresh-agent.sh
./scripts/uninstall-background-refresh-agent.sh
```

## Privacy And Ethics

LeetTracker uses public LeetCode profile data only. It does not use passwords, private cookies, private submissions, or hidden profile data.

Use LeetTracker with your own username or with a username you have permission to track. Do not use it for scraping, bulk lookups, account enumeration, or competitive monitoring.

LeetTracker is independent and is not affiliated with, endorsed by, or sponsored by LeetCode.

See [docs/privacy.md](docs/privacy.md) for the full privacy summary.

## Troubleshooting

If the widget does not show up immediately, open LeetTracker once from Applications, press **Refresh**, then open macOS **Edit Widgets** again. macOS can take a short moment to register new widget extensions.

If macOS blocks the app after download, open **System Settings > Privacy & Security** and allow LeetTracker.

If the widget seems stale, press **Refresh** in the app once. Widgets update about every 2 hours, but macOS controls the exact timing.
