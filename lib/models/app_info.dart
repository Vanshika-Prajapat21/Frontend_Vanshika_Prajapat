/// Customer application data model
class AppInfo {
  final String id;
  final String name;
  final String platform;

  const AppInfo({
    required this.id,
    required this.name,
    required this.platform,
  });

  /// Formatted platform name: "iOS" or "Android"
  String get formattedPlatform {
    final lower = platform.trim().toLowerCase();
    if (lower == 'ios') return 'iOS';
    if (lower == 'android') return 'Android';
    return platform;
  }

  /// Formatted display name as "Name (iOS)" or "Name (Android)"
  String get displayName => '$name ($formattedPlatform)';

  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed App',
      platform: json['platform'] as String? ?? 'Unknown',
    );
  }
}
