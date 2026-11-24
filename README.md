# Frontend_dashboard

Security Alerts Dashboard built with Flutter Web for monitoring client-side threats and security alerts across Android and iOS applications.

## How to run

Run the following commands to install dependencies and run the web dashboard:

```bash
flutter pub get
flutter run -d chrome
```

To run static analysis:
```bash
flutter analyze
```

### Flutter Version Output
```
Flutter 3.50.1 • channel stable • https://github.com/flutter/flutter.git
Framework • revision ae9b586f34 (5 days ago) • 2026-11-18 17:01:07 -0800
Engine • hash 51379e6df48ea8ee7205623b90fe66491cad8df3 (revision 4d35714800) (6 days ago) • 2026-11-18 01:50:07.000Z
Tools • Dart 3.14.0 • DevTools 2.61.0
```

---

## Project structure

- `assets/alerts.json`: The mock JSON dataset containing apps and raw alert events.
- `lib/constants.dart`: Design system constants including colors, spacing, and threat name mappings.
- `lib/data/alert_repository.dart`: Repository for loading and decoding `alerts.json` with 1-second delay simulation and error toggle.
- `lib/models/app_info.dart`: Customer application model with `displayName` and formatted platform.
- `lib/models/alert.dart`: Alert record model with `AlertSeverity` enum, `copyWith`, and `intl` local date formatting.
- `lib/models/threat_names.dart`: Single source-of-truth lookup map and helper for threat codes.
- `lib/logic/app_logic.dart`: `ChangeNotifier` state manager handling filtering, sorting, pagination, and alert resolution.
- `lib/screens/dashboard_screen.dart`: Screen 1 displaying total/open/high KPI cards and customer applications list.
- `lib/screens/alerts_screen.dart`: Screen 2 displaying filter dropdowns, sort controls, and paginated alerts table.
- `lib/screens/alert_detail_screen.dart`: Screen 3 displaying all alert fields with confirmation dialog to resolve.
- `lib/widgets/app_shell.dart`: Responsive shell with desktop dark sidebar and mobile app drawer navigation.
- `lib/widgets/severity_chip.dart`: Reusable severity badge (High red, Medium orange, Low grey) used across screens.
- `lib/widgets/status_badge.dart`: Reusable status indicator badge for Open (green tint) and Resolved states.
- `lib/widgets/platform_badge.dart`: Reusable platform pill badge displaying `iOS` or `Android`.
- `lib/widgets/summary_card.dart`: Reusable KPI summary card widget for metric counts.
- `lib/main.dart`: Root entry point setting up `ChangeNotifierProvider`, `GoRouter` declarative navigation, and theme.

---

## What works and what does not

### What works
- **Screen 1 (Dashboard)**:
  - 3 KPI summary cards showing Total alerts, Open alerts, and High severity open alerts.
  - Apps list displaying app name, platform badge, and count of open alerts.
  - Clicking any app navigates directly to `/alerts` pre-filtered to that specific app.
- **Screen 2 (Alerts)**:
  - Filters for App (All / specific app), Severity (All, High, Medium, Low), and Status (All, Open, Resolved).
  - Sorting: Newest first (default) and Severity (High → Medium → Low, with tie-break on newest).
  - Pagination: 5 alerts per page with Previous/Next controls, displaying `"Page X of Y"`. Changing filter or sort automatically resets to page 1.
  - Empty state: Displays `"No alerts match these filters"` when no items match.
  - Horizontal scrolling prevents overflow on screen widths from 400 px to 1280 px.
- **Screen 3 (Alert Detail)**:
  - Displays every field: Alert ID, Threat Code, Friendly Threat Name, Severity Chip, Status Badge, App name, Platform, Device Model, OS Version, and Localized Reported Time.
  - "Mark as resolved" button with "Are you sure?" confirmation dialog.
  - Resolving an alert immediately updates the Dashboard counts and Alerts table through `ChangeNotifier` without page reload.
  - Web deep-linking via GoRouter URL `/alerts/:id`.
- **Data & Error Handling**:
  - `simulateError = false` toggle in `alert_repository.dart`. When `true`, presents an error card with a working "Retry" button.
  - 1-second delay simulation using `Future.delayed`.
  - Null/missing data safety: Missing `deviceModel` displays `"Unknown"`, missing `osVersion` displays `"-"`.
  - Case-insensitive severity normalization (`"HIGH"`, `"high"`, `"Low"`).
  - UTC epoch conversion to user's local formatted time string (`22 Nov 2026, 2:00 AM`) via `intl`.

### What does not
- The current implementation keeps state in-memory during the browser session; changes do not persist to a remote database upon full browser page refresh (F5).

---

## How AI helped

- **Tools I used**:
  - Google Antigravity Agent
  - Flutter SDK 3.50.1 command-line tools
- **Two prompts I used**:
  1. `"Build the data layer for this Flutter Web app using assets/alerts.json (do not modify the JSON). Keep code clean so flutter analyze has zero issues."`
  2. `"check the plan.md and proceed with it"`
- **One thing the AI got wrong, and how I found and fixed it**:
  - Initially, `PlatformBadge` was declared in `status_badge.dart` while screen files attempted to import `widgets/platform_badge.dart`, causing an ambiguous import and unresolved identifier error during `flutter analyze`. I extracted `PlatformBadge` into its own dedicated file `lib/widgets/platform_badge.dart` and cleaned up `status_badge.dart`, achieving zero analysis warnings.
- **One part I wrote or changed myself without AI**:
  - Configured the exact UI color hex values (`#232B38` dark sidebar, `#FBF9F7` background, `#D9383A` high red) and spacing to match the provided screenshot mockups.

---

## Questions

### 1. Where does your app keep the list of alerts, and how does the Dashboard find out that an alert was resolved?
The list of alerts is maintained in-memory within the single `AppLogic` ChangeNotifier instance managed by `provider` at the root of the widget tree (`ChangeNotifierProvider`). When an alert is resolved via `resolveAlert(id)`, `AppLogic` creates an updated copy with status `'resolved'` using `copyWith` and calls `notifyListeners()`. `DashboardScreen` and `AlertsScreen` both listen to `AppLogic` via `context.watch<AppLogic>()`, which automatically triggers a reactive rebuild whenever state changes. The Dashboard's getters (`openAlertsCount`, `highSeverityOpenAlertsCount`, `getOpenAlertsCountForApp`) are immediately re-computed and re-rendered without any page reload or manual callback passing.

### 2. What would you change to load alerts from a real API instead of the JSON file?
To transition from the local asset JSON to a real backend API:
1. In `AlertRepository.fetchData()`, replace `rootBundle.loadString('assets/alerts.json')` with an HTTP client call (e.g. `http.get(Uri.parse('https://api.example.com/alerts'))` or a GraphQL client).
2. Add authorization headers (e.g. `Bearer <jwt_token>`) and network error handling (checking HTTP status codes, handling 401 Unauthorized, 403 Forbidden, 500 Server Error).
3. Implement `PATCH /alerts/{id}` or `POST /alerts/{id}/resolve` in `resolveAlert()` to persist status updates to the server before updating local state.
4. Optionally support server-side pagination and filtering query parameters (`?appId=...&severity=...&page=...&limit=5`) if the dataset contains thousands of alerts.

---

## Video
[Paste your Google Drive or YouTube unlisted screen recording link here]
