# LeetTracker Installation Guide

1. Move the `LeetTracker.app` into your Applications folder.
2. Right-click the app and choose "Open" (since this is an unsigned beta release, macOS will warn you; clicking Open explicitly bypasses this).
3. Once open, enter your LeetCode username and press Refresh.
4. Go to Edit Widgets on your Mac desktop/Notification Center to add the Progress and Streak widgets.
5. In the app Settings, click "Enable Background Refresh" so your widgets stay up to date.

## Troubleshooting

- **Widgets not showing in Edit Widgets?** Launch the main app at least once. If they still don't show, restart your Mac or wait a few minutes for macOS to register them.
- **Widgets empty after adding them?** Open the main app, enter your username, and click Refresh. The widgets will automatically update.
- **Background Refresh failing?** If clicking the button in the app doesn't work, you can optionally run the included `install-background-refresh-agent.sh` terminal script as your standard user (do NOT run as root/sudo).

Enjoy tracking your LeetCode progress!
