# Release Checklist

Use this checklist when preparing a public macOS release.

Public users should be able to install LeetTracker with Homebrew or a GitHub release zip. Do not publish a release until the app is Developer ID signed, notarized, packaged, and smoke-tested on a clean Mac account.

## Before Building

- Confirm `LeetTrackerWidgetConfiguration.refreshInterval` is set to `2 * 60 * 60`.
- Confirm `scripts/install-background-refresh-agent.sh` defaults to `7200` seconds.
- Confirm the app only requests public solved-count data and does not ask for credentials.
- Confirm the release notes include the independent/non-affiliated LeetCode disclaimer.
- Confirm you are using a Developer ID Application certificate for public distribution, not only an Apple Development certificate.
- Confirm the final app is notarized and stapled before publishing the release.
- Confirm the Homebrew tap exists as `syedhy/homebrew-leettracker`.
- Confirm the generated cask installs the app and exposes the background refresh commands.

## Build The Release Zip

```zsh
scripts/package-release.sh
```

For a public build, use the public-release guard:

```zsh
PUBLIC_RELEASE=1 scripts/package-release.sh
```

That guard fails the build if the app is not signed with a Developer ID Application certificate. It also turns notarization on by default.

Set one of these notarization options before running the public release build:

```zsh
NOTARY_KEYCHAIN_PROFILE=leettracker-notary PUBLIC_RELEASE=1 scripts/package-release.sh
```

or:

```zsh
APPLE_ID="apple-id@example.com" \
APPLE_TEAM_ID="TEAMID1234" \
APPLE_APP_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx" \
PUBLIC_RELEASE=1 scripts/package-release.sh
```

The script submits the app to Apple, waits for approval, staples the ticket, then builds the final release zip.

The script creates:

- `dist/LeetTracker-<version>-macOS.zip`
- `dist/LeetTracker-<version>-macOS.zip.sha256`

## Create The GitHub Release

1. Create a tag named `v<version>`.
2. Upload the zip and `.sha256` file.
3. Include install steps and the privacy/ethics summary in the release notes.

For a public release, do not publish an unnotarized development-signed build. Homebrew users expect a signed and notarized app that opens cleanly on a fresh Mac.

## Generate The Homebrew Cask

```zsh
scripts/generate-homebrew-cask.sh
```

Copy `packaging/homebrew/Casks/leettracker.rb` into the Homebrew tap repository after the GitHub release URL is live.

Expected public install command:

```zsh
brew tap syedhy/leettracker
brew install --cask leettracker
```

The cask should also provide:

```zsh
leettracker-install-background-refresh
leettracker-uninstall-background-refresh
```

These commands install or remove the optional per-user LaunchAgent for 30-minute background refresh.

## Verify The Release Package

```zsh
scripts/verify-release-package.sh
```

The verification script checks zip layout, checksum, code signature, Gatekeeper assessment, and helper scripts. A public release must pass Gatekeeper assessment.

## Manual Smoke Test

1. Download the release zip from GitHub.
2. Move `LeetTracker.app` to `/Applications`.
3. Open the app once and fetch a public username.
4. Add each widget size/type from macOS Edit Widgets.
5. Install the background refresh helper.
6. Quit LeetTracker and verify the widget updates after the next refresh window.
7. Remove the helper and confirm it leaves no LaunchAgent behind.
