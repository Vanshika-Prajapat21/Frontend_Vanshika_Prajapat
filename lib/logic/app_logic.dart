import 'package:flutter/foundation.dart';
import '../data/alert_repository.dart';
import '../models/alert.dart';
import '../models/app_info.dart';

/// Business logic and state management for the Security Alerts Dashboard
class AppLogic extends ChangeNotifier {
  final AlertRepository _repository = AlertRepository();

  List<AppInfo> apps = [];
  List<Alert> alerts = [];

  bool isLoading = true;
  String? errorMessage;

  // Filter & Sort State
  String selectedAppId = 'ALL';
  String selectedSeverity = 'ALL';
  String selectedStatus = 'ALL';
  String sortBy = 'NEWEST'; // 'NEWEST' or 'SEVERITY'

  int currentPage = 1;
  static const int pageSize = 5;

  /// Load data via AlertRepository
  Future<void> loadAlertsData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.fetchData();
      apps = result.apps;
      alerts = result.alerts;
      isLoading = false;
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  // Summary Metrics
  int get totalAlertsCount => alerts.length;
  int get openAlertsCount => alerts.where((a) => a.isOpen).length;
  int get highSeverityOpenAlertsCount =>
      alerts.where((a) => a.isOpen && a.isHighSeverity).length;

  int getOpenAlertsCountForApp(String appId) {
    return alerts.where((a) => a.appId == appId && a.isOpen).length;
  }

  AppInfo? getAppById(String appId) {
    for (final app in apps) {
      if (app.id == appId) return app;
    }
    return null;
  }

  /// Filtered and sorted alerts pipeline
  List<Alert> get filteredAlerts {
    List<Alert> list = List.from(alerts);

    // Filter by App
    if (selectedAppId != 'ALL') {
      list = list.where((a) => a.appId == selectedAppId).toList();
    }

    // Filter by Severity
    if (selectedSeverity != 'ALL') {
      list = list.where((a) => a.severity.label.toLowerCase() == selectedSeverity.toLowerCase()).toList();
    }

    // Filter by Status
    if (selectedStatus != 'ALL') {
      list = list.where((a) => a.status.toLowerCase() == selectedStatus.toLowerCase()).toList();
    }

    // Sorting
    if (sortBy == 'SEVERITY') {
      // High (rank 0), then Medium (rank 1), then Low (rank 2). Inside same severity, newest first.
      list.sort((a, b) {
        final cmp = a.severity.sortRank.compareTo(b.severity.sortRank);
        if (cmp != 0) return cmp;
        return b.reportedAt.compareTo(a.reportedAt);
      });
    } else {
      // Default: Newest first
      list.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
    }

    return list;
  }

  /// Total pages calculation
  int get totalPages {
    final count = filteredAlerts.length;
    if (count == 0) return 1;
    return ((count - 1) ~/ pageSize) + 1;
  }

  /// Paginated alerts for current page (5 per page)
  List<Alert> get paginatedAlerts {
    final list = filteredAlerts;
    if (list.isEmpty) return [];

    final startIndex = (currentPage - 1) * pageSize;
    if (startIndex >= list.length) {
      currentPage = 1;
      return list.take(pageSize).toList();
    }

    return list.skip(startIndex).take(pageSize).toList();
  }

  /// Filter updates reset page back to 1
  void updateFilter({
    String? appId,
    String? severity,
    String? status,
    String? sort,
  }) {
    if (appId != null) selectedAppId = appId;
    if (severity != null) selectedSeverity = severity;
    if (status != null) selectedStatus = status;
    if (sort != null) sortBy = sort;
    currentPage = 1;
    notifyListeners();
  }

  void resetFilters() {
    selectedAppId = 'ALL';
    selectedSeverity = 'ALL';
    selectedStatus = 'ALL';
    sortBy = 'NEWEST';
    currentPage = 1;
    notifyListeners();
  }

  void nextPage() {
    if (currentPage < totalPages) {
      currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (currentPage > 1) {
      currentPage--;
      notifyListeners();
    }
  }

  /// Mark an alert as resolved using copyWith
  void resolveAlert(String alertId) {
    final index = alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      alerts[index] = alerts[index].copyWith(status: 'resolved');
      notifyListeners();
    }
  }
}
