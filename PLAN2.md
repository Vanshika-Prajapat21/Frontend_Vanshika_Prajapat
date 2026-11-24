# PLAN2.md — Bug Fixes & Submission Prep
> Read this FULLY before writing a single line of code.
> These are targeted fixes only — do NOT refactor anything that is already working.

---

## Project Location
```
C:\Users\vansh\Desktop\Frontend_Vanshika_Prajapat\
```

## Flutter SDK Location
```
C:\Users\vansh\development\flutter\bin\flutter.bat
```
Always run flutter as:
```powershell
& "C:\Users\vansh\development\flutter\bin\flutter.bat" <command>
```

---

## Current Status (after Audit)

| Issue | Severity | Rule Violated |
|---|---|---|
| Duplicate threat name maps in 2 files | 🔴 HIGH — instant fail | R6 |
| Alert Detail header overflows at 400 px | 🔴 HIGH — instant fail | R8 |
| OS version `as String?` crashes on integer values | 🟠 MEDIUM — runtime crash | R4 |
| Deep-link to `/alerts/:id` on cold reload silently falls back | 🟠 MEDIUM — broken UX | R1 |
| Leftover crash logs in root directory | 🟡 LOW — unprofessional | — |
| README has placeholder video link (empty) | 🟡 LOW — submission incomplete | R9 |
| Single monolithic git commit — no incremental history | 🟡 LOW — evaluator note | — |

---

## What Is Already Working — DO NOT TOUCH

| File | Status |
|---|---|
| `assets/alerts.json` | ✅ Never modify |
| `pubspec.yaml` | ✅ Leave as-is |
| `lib/constants.dart` | ⚠️ One line group to DELETE (see Fix 1) |
| `lib/models/threat_names.dart` | ✅ This is the ONE TRUE source — keep it |
| `lib/models/alert.dart` | ⚠️ 2 lines to change (see Fix 3) |
| `lib/models/alert_model.dart` | ✅ Leave as-is |
| `lib/models/app_info.dart` | ✅ Leave as-is |
| `lib/data/alert_repository.dart` | ✅ Leave as-is |
| `lib/logic/app_logic.dart` | ✅ Leave as-is |
| `lib/widgets/severity_chip.dart` | ✅ Leave as-is |
| `lib/widgets/status_badge.dart` | ✅ Leave as-is |
| `lib/widgets/platform_badge.dart` | ✅ Leave as-is |
| `lib/widgets/summary_card.dart` | ✅ Leave as-is |
| `lib/widgets/app_shell.dart` | ✅ Leave as-is |
| `lib/screens/dashboard_screen.dart` | ✅ Leave as-is |
| `lib/screens/alerts_screen.dart` | ✅ Leave as-is |
| `lib/screens/alert_detail_screen.dart` | ⚠️ One widget to change (see Fix 2) |
| `lib/main.dart` | ⚠️ One block to change (see Fix 4) |

---

## Fix 1 — Remove Duplicate Threat Map from `constants.dart` (Rule R6)

**File:** `lib/constants.dart`

**Problem:** Lines 53–67 contain a second copy of the threat name map (`threatDisplayNames`) and a duplicate helper function (`getThreatDisplayName`). The rule says one map in one file. The correct file is `lib/models/threat_names.dart`.

**What to delete — remove these exact lines from `lib/constants.dart`:**
```dart
/// Threat names lookup mapping as specified in the test instructions
const Map<String, String> threatDisplayNames = {
  'ROOT_DETECTED': 'Rooted device',
  'JAILBREAK_DETECTED': 'Jailbroken iPhone',
  'HOOKING_FRAMEWORK': 'Hooking tool (like Frida)',
  'SCREEN_OVERLAY': 'Screen overlay',
  'APP_TAMPERED': 'App was modified',
  'EMULATOR': 'Running on an emulator',
  'DEBUGGER_ATTACHED': 'Debugger attached',
};

/// Get friendly threat name or fallback to code as-is
String getThreatDisplayName(String code) {
  return threatDisplayNames[code] ?? code;
}
```

**Result:** `lib/constants.dart` should now end after the `AppSpacing` class (line 51). Nothing else should reference `threatDisplayNames` from constants — the whole app already uses `getThreatDisplayName` from `threat_names.dart` correctly.

**Verify:** After deleting, run:
```powershell
& "C:\Users\vansh\development\flutter\bin\flutter.bat" analyze
```
Expected: `No issues found!`

---

## Fix 2 — Fix 400 px Overflow on Alert Detail Header (Rule R8)

**File:** `lib/screens/alert_detail_screen.dart`

**Problem:** Around line 131, `headerInfo` is a `Row` with `mainAxisSize: MainAxisSize.min`. On a 400 px screen (344 px usable after padding), long threat names like `"Hooking tool (like Frida)"` + severity chip + status badge exceed available width, causing a yellow/black overflow stripe.

**Find this exact block:**
```dart
              final headerInfo = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    alert.threatDisplayName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SeverityChip(severity: alert.severity.label),
                  const SizedBox(width: 8),
                  StatusBadge(status: alert.status),
                ],
              );
```

**Replace it with this — a `Wrap` that wraps onto the next line instead of overflowing:**
```dart
              final headerInfo = Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    alert.threatDisplayName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SeverityChip(severity: alert.severity.label),
                  StatusBadge(status: alert.status),
                ],
              );
```

**Note:** Remove the two `SizedBox(width: 10)` and `SizedBox(width: 8)` — `Wrap`'s `spacing: 8` handles that. Everything else in the file stays identical.

**Verify manually:** In Chrome DevTools, set viewport to 400 px. Navigate to any Alert Detail screen. No yellow/black stripes should appear.

---

## Fix 3 — Bulletproof OS Version Parsing (Rule R4)

**File:** `lib/models/alert.dart`

**Problem:** Lines 88–89 use `as String?` which crashes with a `TypeError` if the JSON contains a numeric value like `{"osVersion": 15}` instead of `{"osVersion": "15"}`. Rule R4 explicitly says the app must never crash on bad data.

**Find this:**
```dart
    final rawDevice = json['deviceModel'] as String?;
    final rawOs = json['osVersion'] as String?;
```

**Replace with:**
```dart
    final rawDevice = json['deviceModel']?.toString();
    final rawOs = json['osVersion']?.toString();
```

`.toString()` works on any JSON value type (String, int, double, bool) without throwing.

**Verify:** Run `flutter analyze` — still 0 issues.

---

## Fix 4 — Fix Cold Deep-Link Crash for `/alerts/:id` (Rule R1)

**File:** `lib/main.dart`

**Problem:** When a user pastes a URL like `http://localhost:XXXX/alerts/al_105` directly into the browser or presses F5, GoRouter runs the route builder before `loadAlertsData()` finishes. The current guard `if (logic.alerts.isEmpty) return const AlertsScreen()` permanently redirects the user away from the detail screen since alerts load asynchronously.

**Find this block inside the `/alerts/:id` GoRoute:**
```dart
          GoRoute(
            path: '/alerts/:id',
            builder: (context, state) {
              final logic = context.read<AppLogic>();
              final id = state.pathParameters['id']!;
              if (logic.alerts.isEmpty) {
                return const AlertsScreen();
              }
              final alert = logic.alerts.firstWhere(
                (a) => a.id == id,
                orElse: () => logic.alerts.first,
              );
              return AlertDetailScreen(alert: alert);
            },
          ),
```

**Replace with:**
```dart
          GoRoute(
            path: '/alerts/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return _AlertDetailLoader(alertId: id);
            },
          ),
```

**Then add this new private widget at the BOTTOM of `main.dart` (after the `MyApp` class):**
```dart
/// Handles deep-linking to an alert detail — waits for data to load first.
class _AlertDetailLoader extends StatelessWidget {
  final String alertId;

  const _AlertDetailLoader({required this.alertId});

  @override
  Widget build(BuildContext context) {
    final logic = context.watch<AppLogic>();

    if (logic.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brandBlue),
      );
    }

    if (logic.errorMessage != null) {
      return const AlertsScreen();
    }

    final alert = logic.alerts.firstWhere(
      (a) => a.id == alertId,
      orElse: () => logic.alerts.first,
    );

    return AlertDetailScreen(alert: alert);
  }
}
```

**Verify:** 
1. Run `flutter analyze` — 0 issues.
2. Run app, navigate to any Alert Detail screen, then press F5 — it should re-show the detail screen correctly after the 1-second load.

---

## Fix 5 — Clean Up Root Directory Before Submission

**Files to DELETE from project root:**
```
flutter_01.log
flutter_02.log
PLAN.md
PERSONAL_GUIDE.md
PLAN2.md   ← (this file, delete it too before submitting)
```

Run:
```powershell
Remove-Item flutter_01.log, flutter_02.log, PLAN.md, PERSONAL_GUIDE.md -ErrorAction SilentlyContinue
```

**Also add these patterns to `.gitignore` to prevent future log clutter:**
```
flutter_*.log
```

---

## Fix 6 — Record Screen Demo & Update README

**File:** `README.md`

**What to record (keep under 5 minutes):**
1. App load → 1-second spinner → Dashboard appears
2. 3 KPI cards show correct values: Total=14, Open=11, High Severity Open=7
3. Click an app → Alerts screen pre-filtered to that app
4. Change Severity filter → page resets to 1
5. Change Sort to "Severity (High → Low)" → High rows come first
6. Click Next/Previous → pagination works
7. Apply a filter with no results → "No alerts match these filters" appears
8. Click an alert row → Alert Detail opens at correct URL (`/alerts/al_xxx`)
9. Click "Mark as resolved" → "Are you sure?" dialog → Confirm → button disappears, status changes
10. Go back to Dashboard → open alert count is decremented
11. Set viewport to 400 px in DevTools → all 3 screens look fine, zero overflow

**After recording, replace this line in `README.md`:**
```
[Paste your Google Drive or YouTube unlisted screen recording link here]
```
with your actual link.

---

## Step Order — Do These In Sequence

```
Step 1  →  Fix 1 (delete duplicate map from constants.dart)
            Run: flutter analyze → must say "No issues found!"

Step 2  →  Fix 2 (Wrap header in alert_detail_screen.dart)
            Run: flutter analyze → must say "No issues found!"
            Manual: open Chrome DevTools at 400px, check detail screen

Step 3  →  Fix 3 (toString in alert.dart)
            Run: flutter analyze → must say "No issues found!"

Step 4  →  Fix 4 (deep-link loader in main.dart)
            Run: flutter analyze → must say "No issues found!"
            Manual: paste /alerts/al_105 URL → verify it loads correctly after 1s

Step 5  →  Fix 5 (delete log files)
            Run: git add -A && git commit -m "fix: resolve R6 R8 R4 and deep-link issues"

Step 6  →  Fix 6 (record video, update README)
            Run: git add README.md && git commit -m "docs: add screen recording link"
```

---

## Final Testing Checklist Before Submitting

- [ ] `flutter analyze` → `No issues found!`
- [ ] Dashboard: Total=14, Open=11, High Severity Open=7
- [ ] `threatNames` map exists in exactly ONE file: `lib/models/threat_names.dart`
- [ ] `constants.dart` has NO `threatDisplayNames` map (deleted)
- [ ] Alert Detail at 400 px viewport → NO yellow/black overflow stripes
- [ ] Null/integer `osVersion` in JSON → app does not crash
- [ ] F5 on `/alerts/al_105` → spinner shows → then correct detail screen
- [ ] "Mark as resolved" updates Dashboard count immediately
- [ ] Pagination resets to Page 1 when any filter or sort changes
- [ ] Empty state message: `"No alerts match these filters"` appears
- [ ] `simulateError = true` → error card with Retry shows (then set back to `false`)
- [ ] `flutter_01.log`, `flutter_02.log`, `PLAN.md`, `PERSONAL_GUIDE.md`, `PLAN2.md` are deleted
- [ ] README has actual screen recording link (not placeholder text)
- [ ] Git has at least 2 commits (fix commit + docs commit)
- [ ] Zip excludes `build/` and `.dart_tool/` folders

---

## Architecture Reminder (Unchanged)

```
MyApp (StatelessWidget)
└── ChangeNotifierProvider<AppLogic>
    └── MaterialApp.router (GoRouter)
        └── ShellRoute → AppShell (sidebar shell)
            ├── GoRoute '/'              → DashboardScreen
            ├── GoRoute '/alerts'        → AlertsScreen
            └── GoRoute '/alerts/:id'    → _AlertDetailLoader → AlertDetailScreen
```

---

## What Done Looks Like

- `flutter analyze` returns `No issues found!`
- Threat name map exists in exactly ONE place
- 400 px viewport on all 3 screens — zero overflow
- Cold URL deep-link to `/alerts/:id` works after data loads
- README has real video link
- Root directory is clean (no logs or planning files)
- Git has descriptive commits
