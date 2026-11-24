import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_dashboard/logic/app_logic.dart';
import 'package:frontend_dashboard/models/alert.dart';
import 'package:frontend_dashboard/models/app_info.dart';

void main() {
  group('Filter and Sort Logic Tests', () {
    late AppLogic logic;

    final mockApps = [
      const AppInfo(id: 'app_1', name: 'QuickPay', platform: 'android'),
      const AppInfo(id: 'app_2', name: 'QuickPay', platform: 'ios'),
      const AppInfo(id: 'app_3', name: 'ShopKart', platform: 'android'),
    ];

    final mockAlerts = [
      const Alert(
        id: 'al_1',
        appId: 'app_1',
        threatType: 'ROOT_DETECTED',
        severity: AlertSeverity.high,
        deviceModel: 'Pixel 7',
        osVersion: '14',
        reportedAt: 1000,
        status: 'open',
      ),
      const Alert(
        id: 'al_2',
        appId: 'app_1',
        threatType: 'SCREEN_OVERLAY',
        severity: AlertSeverity.medium,
        deviceModel: 'Samsung Galaxy A14',
        osVersion: '13',
        reportedAt: 2000,
        status: 'open',
      ),
      const Alert(
        id: 'al_3',
        appId: 'app_2',
        threatType: 'DEBUGGER_ATTACHED',
        severity: AlertSeverity.low,
        deviceModel: 'iPhone 14',
        osVersion: '18.0',
        reportedAt: 3000,
        status: 'resolved',
      ),
      const Alert(
        id: 'al_4',
        appId: 'app_2',
        threatType: 'JAILBREAK_DETECTED',
        severity: AlertSeverity.high,
        deviceModel: 'iPhone 12',
        osVersion: '17.1',
        reportedAt: 4000,
        status: 'open',
      ),
      const Alert(
        id: 'al_5',
        appId: 'app_3',
        threatType: 'HOOKING_FRAMEWORK',
        severity: AlertSeverity.medium,
        deviceModel: 'Redmi Note 12',
        osVersion: '12',
        reportedAt: 5000,
        status: 'resolved',
      ),
      const Alert(
        id: 'al_6',
        appId: 'app_3',
        threatType: 'EMULATOR',
        severity: AlertSeverity.low,
        deviceModel: 'Genymotion',
        osVersion: '10',
        reportedAt: 6000,
        status: 'open',
      ),
    ];

    setUp(() {
      logic = AppLogic();
      logic.apps = List.from(mockApps);
      logic.alerts = List.from(mockAlerts);
    });

    test('Initial metrics calculate correctly', () {
      expect(logic.totalAlertsCount, equals(6));
      expect(logic.openAlertsCount, equals(4));
      expect(logic.highSeverityOpenAlertsCount, equals(2)); // al_1 and al_4
      expect(logic.getOpenAlertsCountForApp('app_1'), equals(2));
      expect(logic.getOpenAlertsCountForApp('app_2'), equals(1));
      expect(logic.getOpenAlertsCountForApp('app_3'), equals(1));
    });

    test('Default sort is newest first (reportedAt descending)', () {
      final list = logic.filteredAlerts;
      expect(list.length, equals(6));
      expect(list[0].id, equals('al_6')); // reportedAt 6000
      expect(list[1].id, equals('al_5')); // reportedAt 5000
      expect(list[2].id, equals('al_4')); // reportedAt 4000
      expect(list[3].id, equals('al_3')); // reportedAt 3000
      expect(list[4].id, equals('al_2')); // reportedAt 2000
      expect(list[5].id, equals('al_1')); // reportedAt 1000
    });

    test('Sort by severity: High -> Medium -> Low with newest tie-breaker', () {
      logic.updateFilter(sort: 'SEVERITY');
      final list = logic.filteredAlerts;

      // High severity alerts (rank 0), newest first: al_4 (4000) then al_1 (1000)
      expect(list[0].id, equals('al_4'));
      expect(list[1].id, equals('al_1'));

      // Medium severity alerts (rank 1), newest first: al_5 (5000) then al_2 (2000)
      expect(list[2].id, equals('al_5'));
      expect(list[3].id, equals('al_2'));

      // Low severity alerts (rank 2), newest first: al_6 (6000) then al_3 (3000)
      expect(list[4].id, equals('al_6'));
      expect(list[5].id, equals('al_3'));
    });

    test('Filter by App returns only alerts for that app', () {
      logic.updateFilter(appId: 'app_1');
      final list = logic.filteredAlerts;
      expect(list.length, equals(2));
      expect(list.every((a) => a.appId == 'app_1'), isTrue);
    });

    test('Filter by Severity returns only matching severity', () {
      logic.updateFilter(severity: 'High');
      final list = logic.filteredAlerts;
      expect(list.length, equals(2));
      expect(list.every((a) => a.severity == AlertSeverity.high), isTrue);
    });

    test('Filter by Status returns only matching status', () {
      logic.updateFilter(status: 'resolved');
      final list = logic.filteredAlerts;
      expect(list.length, equals(2));
      expect(list.every((a) => a.status == 'resolved'), isTrue);
    });

    test('Combined filter works correctly', () {
      logic.updateFilter(appId: 'app_1', severity: 'High', status: 'open');
      final list = logic.filteredAlerts;
      expect(list.length, equals(1));
      expect(list.first.id, equals('al_1'));
    });

    test('Pagination: 5 alerts per page and resets to page 1 on filter update', () {
      expect(logic.totalPages, equals(2)); // 6 items with pageSize 5 = 2 pages
      expect(logic.paginatedAlerts.length, equals(5));

      logic.nextPage();
      expect(logic.currentPage, equals(2));
      expect(logic.paginatedAlerts.length, equals(1));

      // Updating filter resets back to page 1
      logic.updateFilter(appId: 'app_1');
      expect(logic.currentPage, equals(1));
    });

    test('resolveAlert marks alert as resolved and updates metrics', () {
      expect(logic.openAlertsCount, equals(4));
      logic.resolveAlert('al_1');

      final updated = logic.alerts.firstWhere((a) => a.id == 'al_1');
      expect(updated.isResolved, isTrue);
      expect(updated.isOpen, isFalse);
      expect(logic.openAlertsCount, equals(3));
      expect(logic.highSeverityOpenAlertsCount, equals(1));
    });
  });
}
