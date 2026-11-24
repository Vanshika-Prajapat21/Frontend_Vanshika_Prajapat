import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../logic/app_logic.dart';
import '../widgets/platform_badge.dart';
import '../widgets/severity_chip.dart';
import '../widgets/status_badge.dart';

/// Screen 2: Alerts list with filtering, sorting, and pagination
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = context.watch<AppLogic>();
    final paginated = logic.paginatedAlerts;
    final totalFiltered = logic.filteredAlerts.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Alerts',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'View and filter all security alerts',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Filters Row
          _buildFilterBar(context, logic),

          const SizedBox(height: 20),

          // Alerts Table / Card Container
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (totalFiltered == 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                    child: Center(
                      child: Text(
                        'No alerts match these filters',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                else ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 700),
                      child: DataTable(
                        columnSpacing: 24,
                        horizontalMargin: 20,
                        headingRowHeight: 48,
                        dataRowMinHeight: 56,
                        dataRowMaxHeight: 56,
                        headingTextStyle: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        columns: const [
                          DataColumn(label: Text('Threat Name')),
                          DataColumn(label: Text('Severity')),
                          DataColumn(label: Text('App')),
                          DataColumn(label: Text('Device Model')),
                          DataColumn(label: Text('Reported Time')),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: paginated.map((alert) {
                          final app = logic.getAppById(alert.appId);
                          final appName = app?.name ?? 'App';
                          final appPlatform = app?.platform ?? 'Unknown';

                          return DataRow(
                            onSelectChanged: (_) {
                              context.go('/alerts/${alert.id}');
                            },
                            cells: [
                              DataCell(
                                Text(
                                  alert.threatDisplayName,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              DataCell(SeverityChip(severity: alert.severity.label)),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      appName,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    PlatformBadge(platform: appPlatform),
                                  ],
                                ),
                              ),
                              DataCell(
                                Text(
                                  alert.deviceModel,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  alert.formattedReportedTime,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              DataCell(StatusBadge(status: alert.status)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const Divider(color: AppColors.divider, height: 1),

                  // Pagination footer
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Page ${logic.currentPage} of ${logic.totalPages}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: logic.currentPage > 1
                                  ? () => context.read<AppLogic>().previousPage()
                                  : null,
                              icon: const Icon(Icons.chevron_left, size: 18),
                              label: const Text('Previous'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(color: AppColors.cardBorder),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton(
                              onPressed: logic.currentPage < logic.totalPages
                                  ? () => context.read<AppLogic>().nextPage()
                                  : null,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(color: AppColors.cardBorder),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Next'),
                                  SizedBox(width: 4),
                                  Icon(Icons.chevron_right, size: 18),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, AppLogic logic) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // App Filter Dropdown
        _buildDropdownContainer(
          label: 'App',
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: logic.selectedAppId,
              isDense: true,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              items: [
                const DropdownMenuItem(value: 'ALL', child: Text('App: All')),
                ...logic.apps.map(
                  (a) => DropdownMenuItem(
                    value: a.id,
                    child: Text('App: ${a.displayName}'),
                  ),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  context.read<AppLogic>().updateFilter(appId: val);
                }
              },
            ),
          ),
        ),

        // Severity Filter Dropdown
        _buildDropdownContainer(
          label: 'Severity',
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: logic.selectedSeverity,
              isDense: true,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              items: const [
                DropdownMenuItem(value: 'ALL', child: Text('Severity: All')),
                DropdownMenuItem(value: 'High', child: Text('Severity: High')),
                DropdownMenuItem(value: 'Medium', child: Text('Severity: Medium')),
                DropdownMenuItem(value: 'Low', child: Text('Severity: Low')),
              ],
              onChanged: (val) {
                if (val != null) {
                  context.read<AppLogic>().updateFilter(severity: val);
                }
              },
            ),
          ),
        ),

        // Status Filter Dropdown
        _buildDropdownContainer(
          label: 'Status',
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: logic.selectedStatus,
              isDense: true,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              items: const [
                DropdownMenuItem(value: 'ALL', child: Text('Status: All')),
                DropdownMenuItem(value: 'open', child: Text('Status: Open')),
                DropdownMenuItem(value: 'resolved', child: Text('Status: Resolved')),
              ],
              onChanged: (val) {
                if (val != null) {
                  context.read<AppLogic>().updateFilter(status: val);
                }
              },
            ),
          ),
        ),

        // Sort Dropdown
        _buildDropdownContainer(
          label: 'Sort',
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: logic.sortBy,
              isDense: true,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              items: const [
                DropdownMenuItem(value: 'NEWEST', child: Text('Sort: Newest first')),
                DropdownMenuItem(value: 'SEVERITY', child: Text('Sort: Severity (High → Low)')),
              ],
              onChanged: (val) {
                if (val != null) {
                  context.read<AppLogic>().updateFilter(sort: val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownContainer({required String label, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: child,
    );
  }
}
