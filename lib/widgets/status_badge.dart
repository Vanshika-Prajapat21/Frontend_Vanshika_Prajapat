import 'package:flutter/material.dart';
import '../constants.dart';

/// Status badge displaying Open (green tint) or Resolved (grey)
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  bool get isOpen => status.toLowerCase() == 'open';

  @override
  Widget build(BuildContext context) {
    final isItOpen = isOpen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isItOpen ? AppColors.statusOpenBg : AppColors.statusResolvedBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isItOpen ? 'Open' : 'Resolved',
        style: TextStyle(
          color: isItOpen ? AppColors.statusOpenText : AppColors.statusResolvedText,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
