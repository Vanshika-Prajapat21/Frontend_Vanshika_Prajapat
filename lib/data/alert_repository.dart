import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/alert.dart';
import '../models/app_info.dart';

const bool simulateError = false;

/// Repository for loading security alert data from assets/alerts.json
class AlertRepository {
  /// Fetches apps and alerts with simulated 1-second server delay
  Future<({List<AppInfo> apps, List<Alert> alerts})> fetchData() async {
    // Wait 1 second to simulate server response
    await Future.delayed(const Duration(seconds: 1));

    // If simulateError is true, throw an Exception
    if (simulateError) {
      throw Exception('Failed to load data from server (simulateError is enabled).');
    }

    // Load and decode JSON from assets
    final jsonString = await rootBundle.loadString('assets/alerts.json');
    final dynamic decoded = json.decode(jsonString);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Unexpected JSON structure: root must be a map.');
    }

    final rawApps = decoded['apps'] as List<dynamic>? ?? [];
    final apps = rawApps.map((item) => AppInfo.fromJson(item as Map<String, dynamic>)).toList();

    final rawAlerts = decoded['alerts'] as List<dynamic>? ?? [];
    final alerts = rawAlerts.map((item) => Alert.fromJson(item as Map<String, dynamic>)).toList();

    return (apps: apps, alerts: alerts);
  }
}
