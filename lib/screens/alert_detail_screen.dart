import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../logic/app_logic.dart';
import '../models/alert.dart';
import '../widgets/platform_badge.dart';
import '../widgets/severity_chip.dart';
import '../widgets/status_badge.dart';

/// Screen 3: Alert Detail screen with "Mark as resolved" confirmation dialog
class AlertDetailScreen extends StatefulWidget {
  final Alert alert;

  const AlertDetailScreen({
    super.key,
    required this.alert,
  });

  @override
  State<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends State<AlertDetailScreen> {
  late Alert _currentAlert;

  @override
  void initState() {
    super.initState();
    _currentAlert = widget.alert;
  }

  void _confirmResolve() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Are you sure?',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        content: Text(
          'Do you want to mark alert "${_currentAlert.threatDisplayName}" as resolved?',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Resolve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        context.read<AppLogic>().resolveAlert(_currentAlert.id);
        setState(() {
          _currentAlert = _currentAlert.copyWith(status: 'resolved');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final logic = context.watch<AppLogic>();
    final liveAlert = logic.alerts.firstWhere(
      (a) => a.id == _currentAlert.id,
      orElse: () => _currentAlert,
    );
    final alert = liveAlert;
    final app = logic.getAppById(alert.appId);
    final appName = app?.name ?? 'App';
    final appPlatform = app?.formattedPlatform ?? 'Unknown';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navigation Back link
          InkWell(
            onTap: () => context.go('/alerts'),
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back, size: 16, color: AppColors.textPrimary),
                  SizedBox(width: 8),
                  Text(
                    'Back to Alerts',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header: Alert Detail
          const Text(
            'Alert Detail',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Threat Name + Chips + Mark as resolved button
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 650;

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

              final resolveButton = alert.isOpen
                  ? ElevatedButton.icon(
                      onPressed: _confirmResolve,
                      icon: const Icon(Icons.check, size: 16, color: Colors.white),
                      label: const Text(
                        'Mark as resolved',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonDark,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    )
                  : const SizedBox.shrink();

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerInfo,
                    if (alert.isOpen) ...[
                      const SizedBox(height: 14),
                      resolveButton,
                    ],
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  headerInfo,
                  resolveButton,
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          // Details Card
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(28),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 600;

                final leftColumn = Column(
                  children: [
                    _buildDetailRow('Alert ID', Text(alert.id, style: _valueStyle)),
                    _buildDivider(),
                    _buildDetailRow('Threat Code', Text(alert.threatType, style: _valueStyle)),
                    _buildDivider(),
                    _buildDetailRow('Threat Name', Text(alert.threatDisplayName, style: _valueStyle)),
                    _buildDivider(),
                    _buildDetailRow('Severity', SeverityChip(severity: alert.severity.label)),
                    _buildDivider(),
                    _buildDetailRow('Status', StatusBadge(status: alert.status)),
                  ],
                );

                final rightColumn = Column(
                  children: [
                    _buildDetailRow(
                      'App',
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(appName, style: _valueStyle),
                          const SizedBox(width: 6),
                          PlatformBadge(platform: appPlatform),
                        ],
                      ),
                    ),
                    _buildDivider(),
                    _buildDetailRow('Platform', Text(appPlatform, style: _valueStyle)),
                    _buildDivider(),
                    _buildDetailRow('Device Model', Text(alert.deviceModel, style: _valueStyle)),
                    _buildDivider(),
                    _buildDetailRow('OS Version', Text(alert.osVersion, style: _valueStyle)),
                    _buildDivider(),
                    _buildDetailRow('Reported Time', Text(alert.formattedReportedTime, style: _valueStyle)),
                  ],
                );

                if (isNarrow) {
                  return Column(
                    children: [
                      leftColumn,
                      _buildDivider(),
                      rightColumn,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: leftColumn),
                    const SizedBox(width: 48),
                    Expanded(child: rightColumn),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static const TextStyle _labelStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle _valueStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  Widget _buildDetailRow(String label, Widget valueWidget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: _labelStyle),
          valueWidget,
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: AppColors.divider, height: 1);
  }
}
