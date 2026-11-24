# PLAN.md — Security Alerts Dashboard (Flutter Web)
> Hand-off document for the next LLM. Read this fully before writing a single line of code.

---

## Project Location
```
C:\Users\vansh\Desktop\Frontend_Vanshika_Prajapat\
```

## Flutter SDK Location (not on PATH by default)
```
C:\Users\vansh\development\flutter\bin\flutter.bat
```
Always prefix flutter commands:
```powershell
$env:PATH = "C:\Users\vansh\development\flutter\bin;" + $env:PATH; flutter <command>
```

---

## What Is Already Done (DO NOT redo or overwrite these)

The following files are **complete, correct, and passing `flutter analyze`**. Leave them untouched unless a step below explicitly says to modify them.

| File | Status |
|---|---|
| `assets/alerts.json` | ✅ Complete — raw data, never modify |
| `pubspec.yaml` | ✅ Has `intl: ^0.19.0` — needs `provider` and `go_router` added |
| `lib/constants.dart` | ✅ Complete — `AppColors`, `AppSpacing`, `threatDisplayNames` |
| `lib/models/threat_names.dart` | ✅ Complete — 7-entry map + `getThreatDisplayName()` |
| `lib/models/app_info.dart` | ✅ Complete — `AppInfo` with `fromJson`, `displayName`, `formattedPlatform` |
| `lib/models/alert.dart` | ✅ Complete — `AlertSeverity` enum (High=0, Medium=1, Low=2), `Alert` model with `fromJson`, `copyWith`, `formattedReportedTime` via `intl`, null-safe fallbacks |
| `lib/models/alert_model.dart` | ✅ Barrel re-export — harmless, leave it |
| `lib/data/alert_repository.dart` | ✅ Complete — `const bool simulateError = false;` at top, 1s delay, throws on error, loads+parses `assets/alerts.json` |
| `lib/logic/app_logic.dart` | ⚠️ Complete logic, but needs to become `ChangeNotifier` |
| `lib/widgets/severity_chip.dart` | ✅ Complete — High=red, Medium=orange, Low=grey |
| `lib/widgets/status_badge.dart` | ✅ Complete — Open (green), Resolved (grey) |
| `lib/widgets/platform_badge.dart` | ✅ Complete — iOS/Android pill badge |
| `lib/widgets/summary_card.dart` | ✅ Complete — KPI card widget |
| `lib/widgets/app_shell.dart` | ✅ Complete — dark sidebar (desktop) + drawer (mobile <850px) |
| `lib/screens/dashboard_screen.dart` | ⚠️ Complete UI — needs minor Provider refactor |
| `lib/screens/alerts_screen.dart` | ⚠️ Complete UI — needs minor Provider refactor |
| `lib/screens/alert_detail_screen.dart` | ⚠️ Complete UI — needs minor Provider refactor |
| `lib/main.dart` | ❌ Needs full rewrite to use `go_router` + `provider` |

---

## What Still Needs To Be Done

The app works visually and passes `flutter analyze`, but it uses manual `setState` callbacks for navigation and state. The task spec requires `provider` and `go_router`. Your job is to add those two packages and wire them up **without breaking any existing UI or logic**.

### Step 1 — Add packages to `pubspec.yaml`

Add these two lines under `dependencies:` alongside the existing `intl`:
```yaml
provider: ^6.1.2
go_router: ^14.3.0
```
Then run:
```powershell
$env:PATH = "C:\Users\vansh\development\flutter\bin;" + $env:PATH; flutter pub get
```
Confirm it exits with code 0.

---

### Step 2 — Make `AppLogic` a `ChangeNotifier`

**File:** `lib/logic/app_logic.dart`

Changes needed:
1. Add import: `import 'package:flutter/foundation.dart';`
2. Change class declaration to: `class AppLogic extends ChangeNotifier {`
3. At the end of `loadAlertsData()`, after setting `isLoading = false`, call `notifyListeners();`
4. At the end of `resolveAlert(String alertId)`, after updating the alert, call `notifyListeners();`
5. At the end of `updateFilter(...)`, after setting values and `currentPage = 1`, call `notifyListeners();`
6. At the end of `nextPage()`, if page changed, call `notifyListeners();`
7. At the end of `previousPage()`, if page changed, call `notifyListeners();`
8. At the end of `resetFilters()`, call `notifyListeners();`

Do NOT change any existing logic, properties, or method signatures. Only add `extends ChangeNotifier`, the import, and `notifyListeners()` calls.

---

### Step 3 — Rewrite `lib/main.dart` using `go_router` + `provider`

Replace the entire file with the following approach:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'logic/app_logic.dart';
import 'models/alert.dart';
import 'screens/dashboard_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/alert_detail_screen.dart';
import 'widgets/app_shell.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppLogic()..loadAlertsData(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            final location = state.matchedLocation;
            final activeRoute = location == '/' ? 'dashboard' : 'alerts';
            return AppShell(
              activeRoute: activeRoute,
              onSelectDashboard: () => context.go('/'),
              onSelectAlerts: () => context.go('/alerts'),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/alerts',
              builder: (context, state) => const AlertsScreen(),
            ),
            GoRoute(
              path: '/alerts/:id',
              builder: (context, state) {
                final logic = context.read<AppLogic>();
                final id = state.pathParameters['id']!;
                final alert = logic.alerts.firstWhere(
                  (a) => a.id == id,
                  orElse: () => logic.alerts.first,
                );
                return AlertDetailScreen(alert: alert);
              },
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Security Alerts Dashboard',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.buttonDark,
          primary: AppColors.buttonDark,
          surface: AppColors.cardBg,
        ),
      ),
    );
  }
}
```

---

### Step 4 — Refactor `lib/screens/dashboard_screen.dart`

**Goal:** Remove `logic`, `onOpenAppAlerts`, `onRetry` constructor params. Read state from Provider instead.

Changes:
1. Add imports: `import 'package:provider/provider.dart'; import 'package:go_router/go_router.dart';`
2. Change to `StatelessWidget` (no state needed — Provider rebuilds it).
3. Remove constructor params (`logic`, `onOpenAppAlerts`, `onRetry`).
4. Inside `build()`, get logic via: `final logic = context.watch<AppLogic>();`
5. Replace `onOpenAppAlerts(app.id)` with `context.go('/alerts')` after calling `logic.updateFilter(appId: app.id);`
6. Replace `onRetry` callback with: `context.read<AppLogic>().loadAlertsData()`

The UI structure (loading spinner, error card, 3 KPI cards, apps list) stays **100% identical**.

---

### Step 5 — Refactor `lib/screens/alerts_screen.dart`

**Goal:** Remove `logic`, `onSelectAlert`, `onStateChanged` constructor params.

Changes:
1. Add imports: `import 'package:provider/provider.dart'; import 'package:go_router/go_router.dart';`
2. Remove constructor params.
3. Keep as `StatefulWidget` (needed for `setState` on local UI only — no longer needed actually since Provider handles rebuilds, but keeping it is fine).
4. Inside `build()`, get logic via: `final logic = context.watch<AppLogic>();`
5. Replace `widget.onSelectAlert(alert)` (the row tap) with: `context.go('/alerts/${alert.id}')`
6. All filter/sort `setState` calls: replace `setState(() { logic.updateFilter(...); })` with just `context.read<AppLogic>().updateFilter(...)` — Provider's `notifyListeners()` will trigger the rebuild automatically. You can remove `setState` wrappers but it's also fine to keep them (they're harmless).

The table, filters, pagination, empty state UI stays **100% identical**.

---

### Step 6 — Refactor `lib/screens/alert_detail_screen.dart`

**Goal:** Remove `logic`, `onBackToAlerts`, `onAlertResolved` constructor params.

Changes:
1. Add imports: `import 'package:provider/provider.dart'; import 'package:go_router/go_router.dart';`
2. Remove `logic`, `onBackToAlerts`, `onAlertResolved` constructor params. Keep only `alert`.
3. Inside `_confirmResolve()`:
   - Replace `widget.logic.resolveAlert(...)` with `context.read<AppLogic>().resolveAlert(...)`
   - Remove `widget.onAlertResolved()` call — Provider's `notifyListeners()` propagates the update automatically
4. Replace `widget.onBackToAlerts()` with `context.go('/alerts')`
5. The `_currentAlert` local state and `copyWith` for the button/chip update can stay exactly as-is (it's a correct local UI update).

The detail card UI, resolve dialog, Back link stays **100% identical**.

---

### Step 7 — Run `flutter analyze` and fix any issues

```powershell
$env:PATH = "C:\Users\vansh\development\flutter\bin;" + $env:PATH; flutter analyze
```

Expected output:
```
Analyzing Frontend_Vanshika_Prajapat...
No issues found!
```

**Common issues to watch for:**
- Unused imports after removing constructor params → delete them
- `context.go(...)` or `context.read(...)` called outside `build()` → wrap with `WidgetsBinding.instance.addPostFrameCallback` or restructure
- `AppShell` still has `onSelectDashboard`/`onSelectAlerts` params → pass `() => context.go('/')` and `() => context.go('/alerts')` from inside the ShellRoute builder

---

### Step 8 — Final Testing Checklist (Reserve 30 min for this)

Do these **in order** before recording:

- [ ] `flutter analyze` → "No issues found!"
- [ ] `flutter run -d chrome` → app loads, spinner shows for ~1 second, dashboard appears
- [ ] Dashboard: 3 cards show correct counts (Total=14, Open=11, High Severity Open=7 from the JSON)
- [ ] Click an app row → Alerts screen opens pre-filtered to that app
- [ ] Alerts: change App/Severity/Status filter → page resets to 1
- [ ] Alerts: sort by Severity → High rows come first
- [ ] Alerts: click Next/Previous → pagination works
- [ ] Alerts: filter to empty state → "No alerts match these filters" shows
- [ ] Click an alert row → Alert Detail screen opens
- [ ] Alert Detail: "Mark as resolved" button visible for open alerts only
- [ ] Click "Mark as resolved" → "Are you sure?" dialog → Confirm → button disappears, status badge changes to Resolved
- [ ] Go back to Dashboard → open alert count is decremented
- [ ] **400px overflow check**: Chrome DevTools → set viewport to 400px → check all 3 screens for yellow/black overflow stripes
- [ ] **simulateError test**: In `lib/data/alert_repository.dart`, change `const bool simulateError = false;` to `true` → save → hot-restart → error card + Retry button appears → click Retry → still shows error (expected) → change back to `false` → hot-restart → confirms success path

---

## Important Rules

1. **Never modify `assets/alerts.json`**
2. **Never add packages beyond `provider`, `go_router`, `intl`** (already added)
3. **Keep `const bool simulateError = false;` at the top of `lib/data/alert_repository.dart`** — do not move it
4. **`SeverityChip` must stay in its own file** (`lib/widgets/severity_chip.dart`) and be used on at least 2 screens
5. **`flutter analyze` must return "No issues found!" before you are done**
6. **Do not use `Navigator.push` anywhere** — all navigation must go through `GoRouter`

---

## Architecture After This Migration

```
MyApp (StatelessWidget)
└── ChangeNotifierProvider<AppLogic>
    └── MaterialApp.router (GoRouter)
        └── ShellRoute → AppShell (sidebar shell)
            ├── GoRoute '/'          → DashboardScreen (context.watch<AppLogic>)
            ├── GoRoute '/alerts'    → AlertsScreen (context.watch<AppLogic>)
            └── GoRoute '/alerts/:id'→ AlertDetailScreen (context.read<AppLogic>)
```

---

## What Done Looks Like

- `flutter analyze` returns `No issues found!`
- All 3 screens render correctly in Chrome at 1280px and 400px with zero overflow
- Navigating between screens uses URL paths (`/`, `/alerts`, `/alerts/:id`)
- Resolving an alert on Screen 3 immediately updates the counts on Screen 1 (Dashboard)
- `simulateError = true` shows the error card with a Retry button that re-calls `loadAlertsData()`
