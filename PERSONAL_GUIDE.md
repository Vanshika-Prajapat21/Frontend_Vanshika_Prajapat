# Personal Build Guide: Security Alerts Dashboard

This guide outlines the implementation plan for the **Security Alerts Dashboard** Flutter web application.

---

## 1. Exact File-by-File Order of Implementation

Follow this precise sequence to build features systematically without compile breakage or missing dependencies:

1. **`lib/constants.dart`**
   - Finalize colors (`AppColors`), threat name mapping (`threatDisplayNames`), typography, and spacing constants.
2. **`lib/models/alert_model.dart`**
   - Implement data models: `AppInfo`, `AlertModel`, and helper enums (`Severity`, `AlertStatus`).
   - Implement `fromJson` factories with resilient null/missing field handling (e.g., `deviceModel ?? 'Unknown'`, `osVersion ?? '-'`).
   - Implement case-insensitive parsing for severity (`"HIGH"`, `"high"`, `"Low"`).
3. **`lib/logic/app_logic.dart`**
   - Implement state storage (`alerts`, `apps`, `selectedAppFilter`, `selectedSeverityFilter`, `selectedStatusFilter`, `sortBy`, `currentPage`).
   - Implement `loadAlerts()` using `rootBundle.loadString('assets/alerts.json')` with `Future.delayed(Duration(seconds: 1))` and `simulateError` check.
   - Implement metrics getters (`totalAlertsCount`, `openAlertsCount`, `highSeverityOpenAlertsCount`, `getOpenAlertsCountForApp(appId)`).
   - Implement filter and sort pipelines (`filteredAlerts`, `paginatedAlerts`, `totalPages`).
   - Implement `resolveAlert(String alertId)` to mark an alert as resolved and trigger instant reactive updates.
4. **`lib/widgets/severity_chip.dart`**
   - Build the reusable chip widget displaying High (Red), Medium (Orange), Low (Grey) with normalized badge styling.
5. **`lib/widgets/summary_card.dart`**
   - Build the reusable KPI metric card widget (Title, Count, Accent color, Icon/Border).
6. **`lib/screens/dashboard_screen.dart`**
   - Build Screen 1: Top 3 summary cards, list of customer apps displaying `"Name (Platform)"` and open alert count, tap handler navigating to `AlertsScreen` pre-filtered.
7. **`lib/screens/alerts_screen.dart`**
   - Build Screen 2: Filter controls (App, Severity, Status dropdowns/chips), Sort toggle (Newest first vs Severity High->Medium->Low), Paginated list (5 alerts per page with Prev/Next buttons and `"Page X of Y"`), empty state view (`"No alerts match these filters"`), tap on alert navigating to Detail screen.
8. **`lib/screens/alert_detail_screen.dart`**
   - Build Screen 3: Detail card displaying every field (Alert ID, Threat Name, Severity Chip, App name + Platform, Device Model, OS Version, Localized Reported Date/Time, Status).
   - Implement "Mark as resolved" button with "Are you sure?" confirmation dialog (`showDialog`).
9. **`lib/main.dart`**
   - Connect global theme and initial navigation route.

---

## 2. File Responsibilities Summary

- **`lib/constants.dart`**
  - Defines cohesive dark/light UI palette (avoiding default purple).
  - Holds single source-of-truth threat name mapping dictionary (`ROOT_DETECTED` -> "Rooted device", etc.).
  - Defines layout constants (padding, card radius, constrained web max-width: 420px to 1280px responsive bounds).

- **`lib/models/alert_model.dart`**
  - Defines data contracts for `AppInfo` and `AlertModel`.
  - Normalizes case-insensitive severities and maps missing/null values safely without crashing.

- **`lib/logic/app_logic.dart`**
  - Manages in-memory state and operations (filtering, sorting, pagination, error simulation).
  - Reads `assets/alerts.json` and exposes methods to resolve alerts and compute live dashboard stats.

- **`lib/widgets/severity_chip.dart` & `lib/widgets/summary_card.dart`**
  - Reusable presentation components used across Dashboard, Alerts list, and Alert Detail screens.

- **`lib/screens/dashboard_screen.dart`, `alerts_screen.dart`, `alert_detail_screen.dart`**
  - Stateful/stateless screens delivering responsive presentation with `ConstrainedBox`, `SingleChildScrollView`, and error/loading states.

---

## 3. Cheat Sheet: Flutter Widgets & Dart Methods

### Key Built-in Flutter Widgets
- **`Layout & Responsiveness`**: `ConstrainedBox`, `BoxConstraints(maxWidth: ...)`, `SingleChildScrollView`, `SafeArea`, `LayoutBuilder`.
- **`Data Presentation`**: `ListView.builder`, `Card`, `ListTile`, `Chip`, `Wrap`, `Table` / `DataTable`.
- **`State & Async Handling`**: `FutureBuilder` or stateful `isLoading ? CircularProgressIndicator() : ...`.
- **`Navigation & Modals`**: `Navigator.push`, `Navigator.pop`, `showDialog(context: context, builder: ...)`, `AlertDialog`.
- **`Form & Filters`**: `DropdownButton<String>`, `SegmentedButton`, `ChoiceChip`, `ElevatedButton`, `TextButton`, `IconButton`.

### Essential Dart Methods & Idioms
- **Asset Loading**:
  ```dart
  import 'dart:convert';
  import 'package:flutter/services.dart' show rootBundle;
  final jsonString = await rootBundle.loadString('assets/alerts.json');
  final data = json.decode(jsonString);
  ```
- **Date Formatting (Without external package)**:
  ```dart
  final dt = DateTime.fromMillisecondsSinceEpoch(alert.reportedAt, isUtc: true).toLocal();
  final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
  final period = dt.hour >= 12 ? 'PM' : 'AM';
  final formatted = "${dt.day} ${months[dt.month - 1]} ${dt.year}, ${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $period";
  ```
- **Severity Ranking for Sort**:
  ```dart
  int severityWeight(String s) {
    switch (s.toLowerCase()) {
      case 'high': return 3;
      case 'medium': return 2;
      case 'low': return 1;
      default: return 0;
    }
  }
  ```
- **Pagination Slicing**:
  ```dart
  final startIndex = (currentPage - 1) * pageSize;
  final pageItems = filteredList.skip(startIndex).take(pageSize).toList();
  ```

---

## 4. Error Handling & Edge Cases Checklist

- [ ] **Empty States**: If no alerts match filters, display `"No alerts match these filters"` instead of a blank container or index crash.
- [ ] **Missing / Null Data**:
  - Null `deviceModel` must show `"Unknown"`.
  - Null/missing `osVersion` must show `"-"`.
- [ ] **Case-Insensitive Severity**: Handles `"HIGH"`, `"high"`, `"High"`, `"Low"`, etc., uniformly.
- [ ] **Simulated Error & Retry**:
  - `const bool simulateError = false;` toggle in data repository/logic.
  - When `true`, display user-friendly error message with a working "Retry" button (never a red error screen or blank page).
- [ ] **Async Mounted Checks**: Check `if (!mounted) return;` before calling `setState()` after async delays or dialog pops.
- [ ] **Double-tap Prevention**: Disable "Mark as resolved" button or show loading spinner during dialog confirmation to avoid duplicate operations.
- [ ] **Cross-Screen State Sync**: When an alert is resolved in Detail screen, ensure Dashboard counts and Alert list update immediately without requiring page refresh.
- [ ] **Responsive Overflow**: Verify no yellow/black stripes from 400px to 1280px widths using `SingleChildScrollView` or flexible layouts.
- [ ] **Reset Pagination**: Whenever a filter (App, Severity, Status) or sort order changes, reset `currentPage` back to `1`.
