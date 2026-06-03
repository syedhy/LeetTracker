# LeetTracker Production Expansion Plan

Date: 2026-06-03

## Goal

Turn LeetTracker from a polished desktop widget helper into a production-quality macOS app for LeetCode motivation, analytics, planning, and reminders.

The app should stay simple enough to use every day, but useful enough that it becomes the default place to check progress, set goals, plan practice, and keep LeetCode momentum visible without constantly opening LeetCode.

## Current State

The current app already has a good foundation:

- Native macOS SwiftUI app.
- WidgetKit extension with small and medium widgets.
- Shared app group store for username and cached stats.
- LeetCode public profile stats fetch through the current GraphQL endpoint.
- Widget refresh policy set to 30 minutes.
- Manual app refresh requests widget reloads.
- Professional widget visual direction is already started.

The current app is still mostly a setup screen plus summary cards. The next phase should expand it into a real dashboard product.

## Production Guardrails

This project should be treated as a serious production app, so legal and ethical constraints come first.

### Data Access Policy

Use only data that is public, profile-level, and reasonably necessary for the user experience.

Allowed by default:

- Public username.
- Public solved counts by difficulty.
- Public profile metadata if available and confirmed safe to use.
- Public recent activity only if confirmed accessible without auth and not prohibited by LeetCode terms.
- Locally created app data such as goals, reminders, notes, plans, preferences, and widget settings.

Not allowed:

- Asking for or storing LeetCode passwords.
- Asking for LeetCode session cookies.
- Scraping premium content, problem statements, official solutions, editorials, discussions, or private account data.
- Automating submissions, contest actions, or anything that interferes with LeetCode.
- High-frequency polling.
- Reusing LeetCode branding in a way that implies partnership or endorsement.

### Rate Limit Policy

Use conservative refresh behavior:

- Widget automatic refresh: 30 minutes.
- Manual refresh: allowed from the app, with a short debounce.
- Cache every successful response.
- Show saved data when offline or when LeetCode is unavailable.
- Add exponential backoff after repeated failures.
- Never run rapid background loops.

### Brand Policy

The app can say it tracks public LeetCode progress, but it should not look like an official LeetCode product.

Rules:

- Do not use the LeetCode logo as the app icon.
- Do not use LeetCode-owned art, problem text, or official solution content.
- Add a clear settings/about line: "LeetTracker is an independent app and is not affiliated with LeetCode."
- Create an original icon and visual identity.

### Privacy Policy

Keep the app privacy-first:

- Store user data locally by default.
- Avoid analytics/tracking in the first production version.
- Provide a "Clear Local Data" option.
- Explain what data is fetched and how often.
- Do not upload user stats to any third-party server unless a future feature explicitly requires it and the user opts in.

## Data Strategy

The current implementation fetches:

- Username.
- Total solved.
- Easy solved.
- Medium solved.
- Hard solved.
- Last updated timestamp from the app.

Future data should be added only after validating that it is publicly accessible, stable enough, and allowed by policy.

Candidate data fields to research and validate:

- Profile ranking.
- Avatar.
- Country or location, if public.
- Reputation, if public.
- Badges, if public.
- Recent accepted submissions, if public.
- Submission calendar, if public.
- Language stats, if public.
- Skill/topic stats, if public.
- Contest rating, ranking, and history, if public.

Each new data field should go through a small approval checklist before implementation:

- Is the data public without login?
- Is the endpoint stable enough for production?
- Does using it comply with LeetCode terms?
- Is it useful enough to justify another request?
- Can the app cache it safely?
- Can the UI explain what it means?

## Recommended Product Direction

Build LeetTracker around four main surfaces:

1. Dashboard
2. Analytics
3. Goals and planning
4. Widgets and reminders

The app should feel like a quiet productivity tool, not a heavy admin panel. It should open fast, show the important status immediately, and let the user plan the next action without noise.

## Phase 1: App Icon and Brand Polish

Objective: Give LeetTracker a production-ready identity.

Work:

- Create an original app icon.
- Add the icon to the Xcode asset catalog.
- Make sure the icon appears correctly in the Dock, Finder, app switcher, and widget gallery.
- Use a 1024x1024 base icon and platform-scaled variants.
- Use a visual metaphor that feels related to coding progress without copying LeetCode.

Suggested icon directions:

- A dark rounded-square dashboard tile with a glowing progress ring and code bracket.
- A checkmark path moving through three difficulty dots.
- A minimal "LT" monogram with a progress arc.
- A terminal-style card with a rising solved-count graph.

Best recommendation:

Use a dark macOS-style rounded-square icon with a blue progress arc, three small difficulty dots, and a subtle code bracket mark. It matches the current widget aesthetic, reads well at small sizes, and stays legally separate from LeetCode branding.

Exit criteria:

- App has a real icon everywhere macOS displays it.
- Icon is original and does not use LeetCode-owned marks.
- Icon still reads clearly at small sizes.

## Phase 2: App Shell Overhaul

Objective: Replace the setup-first screen with a real app layout.

Recommended layout:

- Left sidebar navigation.
- Main dashboard content area.
- Top toolbar with profile, refresh, time range, and settings.
- Persistent status area for sync health.

Navigation items:

- Dashboard
- Analytics
- Goals
- Planner
- Widgets
- Settings

Toolbar controls:

- Username/profile selector.
- Manual refresh button.
- Time range picker where available.
- Data source/status menu.
- Settings shortcut.

Dashboard content:

- Total solved hero card.
- Difficulty breakdown.
- Goal progress.
- Current weekly plan.
- Recent milestones.
- Widget preview.
- Last successful sync.

Design principles:

- Use native macOS controls where possible.
- Avoid huge empty white areas.
- Prefer structured panels, tables, charts, and compact cards.
- Keep visual density useful but not crowded.
- Use consistent spacing, corner radius, typography, and color tokens.

Exit criteria:

- App feels useful even when opened with no immediate setup task.
- Saved profile loads directly into the dashboard.
- Empty state is attractive and clear.
- The old setup flow still exists, but as part of settings/profile management.

## Phase 3: Analytics Dashboard

Objective: Make the app useful beyond showing the same widget stats.

Core analytics:

- Total solved.
- Easy, medium, hard distribution.
- Difficulty balance.
- Weekly progress.
- Monthly progress.
- Personal best week.
- Streak based on locally observed progress.
- Last sync time.
- Goal completion rate.

Advanced analytics if data is safely available:

- Topic coverage.
- Language usage.
- Recent accepted submissions.
- Contest rating trend.
- Badges timeline.
- Ranking trend.

Charts and visuals:

- Difficulty stacked bar.
- Progress line chart.
- Weekly solved bar chart.
- Goal ring.
- Topic coverage grid.
- Milestone timeline.

Important constraint:

Do not pretend to know data that LeetCode does not expose safely. For example, if the app cannot ethically fetch problem-level history, then topic analytics should be disabled, manually tracked, or clearly marked as unavailable.

Exit criteria:

- User can understand progress at a glance.
- User can see whether they are improving or stalling.
- Analytics never misrepresent stale or unavailable data.

## Phase 4: Goals

Objective: Make LeetTracker motivational and planning-oriented.

Goal types:

- Total solved target.
- Weekly solved target.
- Difficulty-specific targets.
- Topic focus targets, if topic data is available or manually entered.
- Daily practice commitment.
- Interview prep deadline.
- Custom milestone, such as "Reach 200 solved before July 1".

Goal settings:

- Target number.
- Due date.
- Difficulty mix.
- Reminder schedule.
- Reset behavior.
- Widget visibility.

Goal dashboard:

- Active goal card.
- Progress percentage.
- Days remaining.
- Suggested pace.
- On-track/off-track state.
- Next recommended action.

Motivation details:

- Celebrate milestones quietly.
- Show "you need X more this week" instead of vague encouragement.
- Support pause/resume so missed days do not make the product feel hostile.

Exit criteria:

- User can create, edit, pause, complete, and delete goals.
- Goal progress appears in dashboard and widgets.
- Goals are stored locally.

## Phase 5: Planner and Reminders

Objective: Help the user decide what to do next, not just observe stats.

Planner features:

- Weekly practice plan.
- Difficulty mix picker.
- Topic focus picker.
- Study session blocks.
- Manual problem notes or links.
- Review queue.
- Interview target date.

Reminder features:

- Local macOS notifications.
- Daily reminder.
- Weekly review reminder.
- Goal deadline reminder.
- "You are behind pace" reminder.
- Quiet hours.
- Snooze.

Reminder ethics:

- Notifications should be opt-in.
- No guilt-heavy copy.
- No spammy repeated alerts.
- Easy off switch.

Exit criteria:

- User can set reminders without leaving the app.
- Notifications work when the app is closed, using macOS notification scheduling.
- Reminders can be disabled or adjusted from settings.

## Phase 6: Widget Expansion

Objective: Keep widgets as one of the strongest parts of the product.

Current widgets:

- Small progress widget.
- Medium progress widget.

New widget ideas:

- Goal progress widget.
- Weekly pace widget.
- Daily focus widget.
- Difficulty balance widget.
- Milestone countdown widget.
- Streak/progress widget based on locally observed changes.
- Review reminder widget.
- Compact "next session" widget.

Widget configuration:

- Choose profile.
- Choose widget type.
- Choose visible metric.
- Choose goal.
- Choose theme.

Refresh rules:

- Automatic refresh remains 30 minutes.
- Manual refresh from app requests immediate reload.
- Widget timeline always uses cached data if LeetCode is unreachable.
- Widget copy should show real last updated time, not "0 sec" forever.

Exit criteria:

- At least 3 useful widget types exist.
- Widget state is clear: fresh, cached/offline, no profile, or error.
- Widgets remain visually balanced in small and medium sizes.

## Phase 7: Production Architecture

Objective: Keep the app maintainable as features grow.

Recommended structure:

- `Domain`
  - `LeetCodeProfile`
  - `LeetCodeStats`
  - `Goal`
  - `Reminder`
  - `AnalyticsSnapshot`
- `Data`
  - `LeetCodeClient`
  - `LeetTrackerRepository`
  - `GoalStore`
  - `ReminderStore`
  - `CacheStore`
- `Services`
  - `AnalyticsEngine`
  - `ReminderScheduler`
  - `WidgetRefreshCoordinator`
  - `RateLimiter`
- `Presentation`
  - Dashboard view models.
  - Analytics view models.
  - Goals view models.
  - Settings view models.
- `UI`
  - Shared visual components.
  - Charts.
  - Buttons.
  - Panels.
  - Empty states.

Storage recommendation:

- Continue using the App Group file-backed shared store for small widget state.
- Use SwiftData or a lightweight local JSON store for goals, history snapshots, reminders, and preferences.
- Store widget-specific snapshots separately so widget rendering stays fast.

Network recommendation:

- Keep all LeetCode network access in one client.
- Add request logging in debug builds only.
- Add timeout handling, backoff, and endpoint-change errors.
- Add schema tests around decoding.

Exit criteria:

- App and widget share model definitions where appropriate.
- Widget code does not own business logic.
- New dashboard features do not make the widget fragile.

## Phase 8: Quality, Testing, and Release Readiness

Objective: Make the app professional enough to ship.

Testing:

- Unit tests for LeetCode response decoding.
- Unit tests for goal progress math.
- Unit tests for reminder scheduling rules.
- Unit tests for widget snapshot formatting.
- UI previews for empty/loading/success/error states.
- Manual install test from `/Applications/LeetTracker.app`.

Production checklist:

- App icon present.
- App name and bundle identifiers correct.
- Signing configured.
- Widget appears after install.
- Widget updates with app closed.
- Manual refresh works.
- Privacy/about screen present.
- Clear data action present.
- No private LeetCode auth collection.
- No high-frequency polling.
- No LeetCode logo usage.

Potential distribution paths:

- Personal signed app first.
- Notarized macOS app next.
- App Store only after checking whether the data access model is acceptable for review.

## Suggested Extra Improvements

These are worth considering beyond the requested list:

- Menu bar status item showing solved count and next goal.
- Shareable progress card image generated locally.
- Weekly review screen with "what changed this week".
- Lightweight study journal.
- Import manual solved-history snapshots so analytics can start before the app has weeks of observed data.
- Custom themes for widgets.
- Backup/export local app data.
- Keyboard shortcuts for refresh, new goal, and quick planner entry.
- Onboarding that explains exactly what data is public and what stays local.
- A "data health" panel showing last fetch, next widget refresh, cache age, and source limitations.

## Ideas To Reject Or Defer

Reject:

- LeetCode account login.
- Cookie/session import.
- Scraping premium problem content.
- Scraping problem statements or official solutions.
- Any feature implying official LeetCode partnership.
- Refreshing widgets every minute in production.
- Automating practice or submissions on LeetCode.

Defer:

- Cloud sync.
- Multi-user profiles.
- Social comparison.
- Public leaderboards.
- AI study recommendations based on private submission history.
- Push notifications from a backend.

These can be revisited only after the core app is stable and the data access policy is settled.

## Build Order

Recommended implementation order:

1. Add app icon and brand assets.
2. Create production app shell with sidebar navigation.
3. Move current setup flow into Settings/Profile.
4. Build Dashboard screen from existing stats.
5. Add local history snapshots on each successful refresh.
6. Build basic analytics from locally observed history.
7. Add goals.
8. Add local reminders.
9. Add goal and planner widgets.
10. Add data health/settings/privacy screen.
11. Re-check legal/data source assumptions before distribution.

This order keeps the app useful quickly while avoiding risky data expansion too early.

## First Concrete Milestone

Milestone: "Production shell and icon"

Scope:

- App icon added.
- Sidebar app shell added.
- Dashboard becomes first screen.
- Current username setup moves into profile/settings panel.
- Current stats cards are redesigned into dashboard modules.
- Widget behavior stays unchanged.

Why this first:

- It makes the app feel like a real product immediately.
- It does not require new LeetCode data fields.
- It gives a stable UI foundation for goals, reminders, and analytics.

## Second Concrete Milestone

Milestone: "Goals and local analytics"

Scope:

- Store local stat snapshots after each successful refresh.
- Add weekly/monthly progress charts from local history.
- Add goal creation and progress tracking.
- Add goal progress widget.
- Add local notification reminders.

Why this second:

- It makes the app genuinely useful.
- It can work ethically with current public stats.
- It does not depend on unstable private data.

## Open Questions

Before production distribution, answer these:

- Are we comfortable relying on LeetCode's current GraphQL endpoint for public stats?
- Should the app remain personal-use first, or target public distribution?
- Should goals be fully local, or should any future sync exist?
- What exact icon direction should we choose?
- Which widgets matter most: goals, planner, analytics, or motivation?
- Should reminders be daily habit reminders, deadline-based reminders, or both?

## Source Notes

- [LeetCode Terms of Service](https://leetcode.com/terms/) restrict automated crawling/scraping, password/security info collection, and processes that create undue load or interfere with the service.
- [Apple App Icons](https://developer.apple.com/design/human-interface-guidelines/app-icons) guidance expects a distinct, recognizable icon and lists 1024x1024 px as the platform layout size for iOS, iPadOS, and macOS app icons.
- [Apple WidgetKit TimelineProvider](https://developer.apple.com/documentation/widgetkit/timelineprovider) documentation describes timeline providers as the system-facing mechanism for advising WidgetKit when to update a widget display.
- [Apple UserNotifications time interval trigger](https://developer.apple.com/documentation/usernotifications/untimeintervalnotificationtrigger) documentation supports local notification scheduling by elapsed time.
