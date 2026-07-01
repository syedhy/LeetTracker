# LeetTracker

LeetTracker is a free macOS app that shows your LeetCode progress and streak in desktop widgets.

It lets you enter a LeetCode username, view solved problem stats, add widgets to your desktop, and enable background refresh so the widgets can keep updating even when the app is closed.

> Current release : `v1.0.0-beta`  
> Current status : free unsigned macOS beta

---

## Important first-launch note

LeetTracker is currently **unsigned** because it is not Apple-notarized yet.

That means macOS may block the app the first time you open it.

You may see a warning like:

> Apple could not verify “LeetTracker.app” is free of malware that may harm your Mac or compromise your privacy

This is expected for the current beta.

If you see this message, **do not click Move to Trash** if you want to use the app.

Click **Done**, then follow the steps below.

### How to open LeetTracker on first launch

1. Click **Done** on the macOS warning
2. Open **System Settings**
3. Go to **Privacy & Security**
4. Scroll down near the bottom
5. Look for a message saying `LeetTracker.app` was blocked
6. Click **Open Anyway**
7. Confirm by clicking **Open**

After this, LeetTracker should open normally.

This first-launch step is only needed because the current beta is not signed/notarized yet. Future signed versions should have a smoother opening experience.

---

## Features

- Track public LeetCode stats using a username
- Progress widget for solved problem counts
- Streak widget for practice consistency
- Manual refresh from inside the app
- Background Refresh support
- Widgets can update even after the app is closed
- No LeetCode login required
- No password required
- Data is stored locally on your Mac

---

## Download options

You can install LeetTracker in two ways.

---

## Option 1 : Download ZIP

Download the latest beta ZIP here:

[Download LeetTracker for macOS](https://github.com/syedhy/LeetTracker/releases/download/v1.0.0-beta/LeetTracker-1.0-macOS.zip)

### Install steps

1. Download `LeetTracker-1.0-macOS.zip`
2. Unzip the file
3. Move `LeetTracker.app` to the **Applications** folder
4. Open LeetTracker using the unsigned app instructions above
5. Enter your LeetCode username
6. Press **Save**
7. Press **Refresh**
8. Add the Progress and Streak widgets
9. Enable **Background Refresh** from Settings

---

## Option 2 : Install with Homebrew

Run these commands in Terminal:

```bash
brew tap syedhy/leettracker
brew trust --cask syedhy/leettracker/leettracker
brew install --cask syedhy/leettracker/leettracker
```

Then open LeetTracker from the **Applications** folder.

If macOS blocks the app on first launch, follow the **Important first-launch note** above.

After opening the app:

1. Enter your LeetCode username
2. Press **Save**
3. Press **Refresh**
4. Add the widgets
5. Enable **Background Refresh** from Settings

---

## First setup

After opening LeetTracker:

1. Go to the Dashboard or Settings page
2. Enter your LeetCode username
3. Press **Save**
4. Press **Refresh**
5. Wait for your stats to appear
6. Add the widgets
7. Enable **Background Refresh** from Settings

---

## How to add widgets

1. Right-click your desktop
2. Click **Edit Widgets**
3. Search for **LeetTracker**
4. Add the **Progress** widget
5. Add the **Streak** widget

LeetTracker currently includes exactly two widgets:

- Progress widget
- Streak widget

---

## Background Refresh

Background Refresh lets LeetTracker update widget data even when the main app is closed.

To enable it:

1. Open LeetTracker
2. Go to **Settings**
3. Click **Enable Background Refresh**

Once enabled, the app does not need to stay open.

LeetTracker schedules refreshes about every 2 hours. macOS controls the exact timing, so updates may not happen at the exact minute.

---

## Troubleshooting

### App will not open

This is the most common issue with the current beta.

Because LeetTracker is unsigned, macOS may show:

> Apple could not verify “LeetTracker.app” is free of malware that may harm your Mac or compromise your privacy

To fix it:

1. Click **Done**
2. Open **System Settings**
3. Go to **Privacy & Security**
4. Scroll down near the bottom
5. Find the message about `LeetTracker.app` being blocked
6. Click **Open Anyway**
7. Confirm by clicking **Open**
8. Try opening LeetTracker again

Do not click **Move to Trash** unless you want to remove the app.

Some macOS versions may also allow this:

1. Open Finder
2. Go to **Applications**
3. Right-click `LeetTracker.app`
4. Choose **Open**
5. Confirm **Open**

If right-click Open does not work, use **System Settings → Privacy & Security → Open Anyway**.

---

### Widgets do not appear

Try these steps:

1. Make sure `LeetTracker.app` is inside the **Applications** folder
2. Open LeetTracker once
3. Wait a few seconds
4. Open **Edit Widgets** again
5. Search for **LeetTracker**

If it still does not appear, log out and log back in, or restart your Mac.

---

### Widgets say “add username”

Open LeetTracker and check that:

1. Your LeetCode username is entered
2. You pressed **Save**
3. You pressed **Refresh**
4. Your stats are visible in the app

Then remove and re-add the widgets if needed.

---

### Widgets do not update immediately

Widgets may not update instantly because macOS controls widget refresh timing.

Try:

1. Open LeetTracker
2. Press **Refresh**
3. Wait a few seconds
4. Remove and re-add the widget if needed

If Background Refresh is enabled, widgets should continue updating in the background about every 2 hours.

---

### Background Refresh does not enable

Check:

1. `LeetTracker.app` is inside the **Applications** folder
2. The app was opened at least once
3. You clicked **Enable Background Refresh** from Settings

If it still fails, open a GitHub Issue and include the error message shown in the app.

---

### Homebrew says the tap or cask is not trusted

Run:

```bash
brew trust --cask syedhy/leettracker/leettracker
```

Then install again:

```bash
brew install --cask syedhy/leettracker/leettracker
```

---

### Homebrew install fails

Try:

```bash
brew update
brew tap syedhy/leettracker
brew trust --cask syedhy/leettracker/leettracker
brew install --cask syedhy/leettracker/leettracker
```

If Homebrew says the cask is already installed, uninstall and reinstall:

```bash
brew uninstall --cask leettracker
brew install --cask syedhy/leettracker/leettracker
```

---

## Privacy

LeetTracker only uses the LeetCode username you enter.

LeetTracker:

- Fetches public LeetCode profile/stat data
- Does not ask for your LeetCode password
- Does not require LeetCode login
- Stores data locally on your Mac
- Does not include analytics or user tracking

---

## Uninstall

### Manual uninstall

1. Open LeetTracker
2. Disable **Background Refresh** from Settings
3. Delete `LeetTracker.app` from the **Applications** folder

### Homebrew uninstall

```bash
brew uninstall --cask leettracker
```

### Full Homebrew cleanup

```bash
brew zap leettracker
```

This removes the app and related local support files.

---

## Developer notes

LeetTracker is built with:

- SwiftUI
- WidgetKit
- LaunchAgent background refresh
- Local JSON/shared storage for widget data

Current release mode:

```text
FREE_UNSIGNED_RELEASE
```

Future versions may be signed and notarized after an Apple Developer account is available.

---

## Links

- Main repository : https://github.com/syedhy/LeetTracker
- Latest release : https://github.com/syedhy/LeetTracker/releases/tag/v1.0.0-beta
- Direct download : https://github.com/syedhy/LeetTracker/releases/download/v1.0.0-beta/LeetTracker-1.0-macOS.zip
- Homebrew tap : https://github.com/syedhy/homebrew-leettracker
