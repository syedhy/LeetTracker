# LeetTracker

LeetTracker is a macOS app and desktop widget for keeping LeetCode progress visible. It uses public LeetCode profile stats, lets you set practice goals, and keeps the widget refreshed through a local background helper.

## Current Status

This app is still in active development. The widget, goal settings, reminders, dashboard, and analytics pages are working, but the release packaging flow is still being polished.

## Download And Install

### Option 1: GitHub Release

When a release is published:

1. Open the repository's **Releases** page.
2. Download the latest `LeetTracker-macOS.zip`.
3. Unzip it.
4. Move `LeetTracker.app` to `/Applications`.
5. Open the app once, enter your LeetCode username, and press **Refresh**.
6. Add the LeetTracker widget from macOS **Edit Widgets**.
7. Double-click **Install Background Refresh.command** if you want the widget to refresh while the app window is closed.

If macOS warns that the app was downloaded from the internet, open **System Settings > Privacy & Security** and allow LeetTracker.

### Option 2: Build From Source

Use this while the app is still being developed.

Requirements:

- macOS 14 or newer
- Xcode
- An Apple account added in Xcode for local signing

Steps:

```zsh
git clone https://github.com/syedhy/LeetTracker.git
cd LeetTracker
open LeetTracker.xcodeproj
```

In Xcode:

1. Select the `LeetTracker` scheme.
2. Select **My Mac** as the destination.
3. Build and run the app.
4. Enter your LeetCode username and press **Refresh**.

To install the built app into `/Applications`, build a Release version and copy it:

```zsh
xcodebuild -scheme LeetTracker -configuration Release -derivedDataPath build CODE_SIGN_STYLE=Automatic build
ditto --rsrc --extattr build/Build/Products/Release/LeetTracker.app /Applications/LeetTracker.app
```

To create the same zip format used for GitHub releases:

```zsh
scripts/package-release.sh
```

The packaged zip is written to `dist/LeetTracker-macOS.zip`.

## Widget Setup

After installing the app:

1. Open `/Applications/LeetTracker.app` once.
2. Save your LeetCode username.
3. Press **Refresh** to fetch your public solved counts.
4. Open macOS **Edit Widgets**.
5. Search for **LeetTracker**.
6. Add the small or medium widget.

If the widget does not appear immediately, restart the app once or log out and back in. macOS can take a moment to register new widget extensions.

## Background Refresh

LeetTracker includes a LaunchAgent helper so the widget can refresh even when the app window is closed.

Install the helper:

```zsh
APP_PATH=/Applications/LeetTracker.app scripts/install-background-refresh-agent.sh
```

Uninstall the helper:

```zsh
scripts/uninstall-background-refresh-agent.sh
```

The helper only runs LeetTracker's background refresh command. It reads the saved username, fetches public LeetCode stats, updates the shared widget data, and exits.

## Features

- Public LeetCode profile stat tracking
- Desktop widgets for quick solved-count visibility
- Manual refresh from the app
- Background widget refresh through a local LaunchAgent
- Goal setting with weekly difficulty targets
- Practice reminders
- Dashboard summary
- Analytics based on current LeetCode stats and saved goals
- Monochrome doodle-inspired interface with Easy, Medium, and Hard difficulty colors

## Data And Ethics

LeetTracker uses public LeetCode profile information only. It does not scrape private data, bypass authentication, or pretend to provide an official LeetCode score. Analytics are local practice signals based on public solved counts and user-defined goals.

## Roadmap

- Publish packaged GitHub releases for one-click downloads
- Publish a Homebrew Cask as the recommended installation path
- Move background refresh setup into the app settings screen
- Add signing and notarization notes for public macOS distribution
- Add clearer onboarding for first-time users
- Improve analytics with more useful goal and difficulty visualizations
- Add more widget types
- Make reminder and goal planning more flexible
- Add a polished release checklist and troubleshooting section
