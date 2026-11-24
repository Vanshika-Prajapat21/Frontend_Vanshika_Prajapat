import 'package:flutter/material.dart';
import '../constants.dart';

/// Reusable severity chip widget used across Alerts and Alert Detail screens (Rule R7)
/// Colours: High red, Medium orange, Low grey.
class SeverityChip extends StatelessWidget {
  final String severity;

  const SeverityChip({
    super.key,
    required this.severity,
  });

  Color _getBackgroundColor() {
    switch (severity.toLowerCase()) {
      case 'high':
        return AppColors.severityHigh;
      case 'medium':
        return AppColors.severityMedium;
      case 'low':
      default:
        return AppColors.severityLow;
    }
  }

  String _getDisplayText() {
    switch (severity.toLowerCase()) {
      case 'high':
        return 'High';
      case 'medium':
        return 'Medium';
      case 'low':
        return 'Low';
      default:
        return severity;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getDisplayText(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
