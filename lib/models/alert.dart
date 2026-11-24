import 'package:intl/intl.dart';
import 'threat_names.dart';

/// Severity enum with labels High, Medium, Low and sort rank High (0), Medium (1), Low (2)
enum AlertSeverity {
  high('High', 0),
  medium('Medium', 1),
  low('Low', 2);

  final String label;
  final int sortRank;

  const AlertSeverity(this.label, this.sortRank);

  /// Case-insensitive normalization
  static AlertSeverity fromString(String? raw) {
    if (raw == null) return AlertSeverity.low;
    final lower = raw.trim().toLowerCase();
    if (lower == 'high') return AlertSeverity.high;
    if (lower == 'medium') return AlertSeverity.medium;
    if (lower == 'low') return AlertSeverity.low;
    return AlertSeverity.low;
  }
}

/// Alert record model
class Alert {
  final String id;
  final String appId;
  final String threatType;
  final AlertSeverity severity;
  final String deviceModel;
  final String osVersion;
  final int reportedAt;
  final String status;

  const Alert({
    required this.id,
    required this.appId,
    required this.threatType,
    required this.severity,
    required this.deviceModel,
    required this.osVersion,
    required this.reportedAt,
    required this.status,
  });

  bool get isOpen => status.toLowerCase() == 'open';
  bool get isResolved => status.toLowerCase() == 'resolved';
  bool get isHighSeverity => severity == AlertSeverity.high;

  /// Human-readable threat name via threat_names mapping
  String get threatDisplayName => getThreatDisplayName(threatType);

  /// Local time formatted as "22 Nov 2026, 2:00 AM" using intl
  String get formattedReportedTime {
    if (reportedAt <= 0) return '-';
    final localDt = DateTime.fromMillisecondsSinceEpoch(reportedAt, isUtc: true).toLocal();
    final formatter = DateFormat('d MMM yyyy, h:mm a');
    return formatter.format(localDt);
  }

  /// copyWith to support updating status (e.g. to 'resolved')
  Alert copyWith({
    String? id,
    String? appId,
    String? threatType,
    AlertSeverity? severity,
    String? deviceModel,
    String? osVersion,
    int? reportedAt,
    String? status,
  }) {
    return Alert(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      threatType: threatType ?? this.threatType,
      severity: severity ?? this.severity,
      deviceModel: deviceModel ?? this.deviceModel,
      osVersion: osVersion ?? this.osVersion,
      reportedAt: reportedAt ?? this.reportedAt,
      status: status ?? this.status,
    );
  }

  factory Alert.fromJson(Map<String, dynamic> json) {
    // Missing deviceModel -> "Unknown", missing osVersion -> "-"
    final rawDevice = json['deviceModel'] as String?;
    final rawOs = json['osVersion'] as String?;

    return Alert(
      id: json['id'] as String? ?? '',
      appId: json['appId'] as String? ?? '',
      threatType: json['threatType'] as String? ?? 'UNKNOWN_THREAT',
      severity: AlertSeverity.fromString(json['severity'] as String?),
      deviceModel: (rawDevice != null && rawDevice.trim().isNotEmpty)
          ? rawDevice.trim()
          : 'Unknown',
      osVersion: (rawOs != null && rawOs.trim().isNotEmpty)
          ? rawOs.trim()
          : '-',
      reportedAt: (json['reportedAt'] as num?)?.toInt() ?? 0,
      status: (json['status'] as String? ?? 'open').trim().toLowerCase(),
    );
  }
}
