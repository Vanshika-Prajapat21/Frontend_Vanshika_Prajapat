import 'package:flutter/material.dart';
import '../constants.dart';

/// Small platform badge next to app names (e.g. "iOS", "Android")
class PlatformBadge extends StatelessWidget {
  final String platform;

  const PlatformBadge({
    super.key,
    required this.platform,
  });

  String get formattedPlatform {
    if (platform.toLowerCase() == 'ios') return 'iOS';
    if (platform.toLowerCase() == 'android') return 'Android';
    return platform;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.platformBadgeBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.platformBadgeBorder),
      ),
      child: Text(
        formattedPlatform,
        style: const TextStyle(
          color: AppColors.platformBadgeText,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
