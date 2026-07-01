# LeetTracker

LeetTracker is a free macOS app that shows your LeetCode progress and streak in desktop widgets.

## Screenshots

![Main App Screenshot](placeholders/main-app.png)
*Main Application View*

![Progress Widget Screenshot](placeholders/progress-widget.png)
*Progress Widget*

![Streak Widget Screenshot](placeholders/streak-widget.png)
*Streak Widget*

![Settings Screenshot](placeholders/settings.png)
*Settings & Background Refresh*

## Features

- **Track LeetCode stats**: View your solved problems (Easy, Medium, Hard) and overall rank.
- **Progress widget**: A beautiful desktop widget showing your current problem-solving progress.
- **Streak widget**: Keep yourself accountable with a daily streak widget on your desktop.
- **Manual refresh**: Update your stats instantly from the app.
- **Background Refresh**: Keeps your widgets updated automatically without keeping the app open.
- **Easy installation**: Works from a normal ZIP download or Homebrew.

## Install Option 1: Download ZIP

1. Download `LeetTracker-1.0-macOS.zip` from the latest [GitHub Release](https://github.com/syedhy/LeetTracker/releases).
2. Unzip the file.
3. Move `LeetTracker.app` to your Applications folder.
4. Since the app is currently unsigned, macOS may show a warning when you try to open it.
5. If blocked, right-click `LeetTracker.app` in your Applications folder and choose **Open**.
6. Click **Open** again on the prompt.
7. Enter your LeetCode username in the app.
8. Press **Refresh**.
9. Add the widgets from your Mac's **Edit Widgets** menu.
10. Enable **Background Refresh** from the app's Settings.

## Install Option 2: Homebrew

You can install LeetTracker easily using Homebrew:

```bash
brew tap syedhy/leettracker
brew install --cask leettracker
```

After installation, open LeetTracker once, enter your username, press Refresh, add your widgets, and enable Background Refresh from Settings.

## First Setup

Getting started is quick and easy:
- Open LeetTracker.
- Enter your LeetCode username.
- Press **Save / Refresh**.
- Add the widgets to your desktop.
- Enable **Background Refresh** in Settings to keep them updated automatically.

## How to Add Widgets

- Right-click anywhere on your Mac desktop.
- Click **Edit Widgets**.
- Search for **LeetTracker** in the widget gallery.
- Add the **Progress** widget.
- Add the **Streak** widget.

## Background Refresh

- Background Refresh lets your widgets keep updating after the app is closed.
- Enable it once from the **Settings** menu inside the app.
- It runs roughly every 2 hours (macOS may adjust the exact timing to optimize battery life).
- The main app does not need to stay open for background refresh to work.

## Unsigned App Warning

- **The current version is unsigned.** This does not mean the app is broken or unsafe.
- macOS shows a warning because the app is not yet notarized by Apple.
- Right-clicking the app and selecting **Open** is required *only the first time* you launch it.
- Future versions may be signed and notarized once an Apple Developer account is obtained.

## Troubleshooting

- **App cannot be opened**: Right-click the app in Finder and choose "Open" to bypass the macOS security warning for unsigned apps.
- **Widgets do not appear**: Open the main app at least once. If they still don't appear in the widget gallery, restart your Mac.
- **Widgets say "add username"**: Open the app, ensure your username is entered correctly, and press Refresh.
- **Background Refresh does not enable**: Ensure the app is installed in the `/Applications` folder, not Downloads. You can check the app Diagnostics in Settings for specific errors.
- **Widgets do not update immediately**: Widgets update on a schedule controlled by macOS. To force an immediate update, open the app and press Refresh.
- **Homebrew install fails**: Ensure your Homebrew is up to date (`brew update`).
- **How to reset app data**: Delete `/Users/YourUsername/Library/Application Support/LeetTrackerShared` and reopen the app.

## Privacy

- LeetTracker only uses the LeetCode username you provide.
- It only fetches public LeetCode profile and stat data.
- All data is stored locally on your Mac.
- No tracking or analytics of any kind.
- No account login or password required.

## Uninstall

**Manual Uninstall:**
1. Open LeetTracker, go to Settings, and click **Disable Background Refresh**.
2. Delete `LeetTracker.app` from your Applications folder.

**Homebrew Uninstall:**
```bash
brew uninstall --cask leettracker
brew zap leettracker
```

## Developer Notes

- Built with SwiftUI.
- Uses WidgetKit for desktop widgets.
- Uses a LaunchAgent for macOS background refresh.
- Current release mode is `FREE_UNSIGNED_RELEASE`.
