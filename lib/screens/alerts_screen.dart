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

  static const TextStyle _headerStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

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
                  // Full-width table expanding across 100% of card width
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double tableWidth =
                          constraints.maxWidth > 750 ? constraints.maxWidth : 750;

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: tableWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Table Header Row
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom:
                                        BorderSide(color: AppColors.divider),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Expanded(
                                      flex: 24,
                                      child: Text('Threat Name',
                                          style: _headerStyle),
                                    ),
                                    Expanded(
                                      flex: 12,
                                      child:
                                          Text('Severity', style: _headerStyle),
                                    ),
                                    Expanded(
                                      flex: 18,
                                      child: Text('App', style: _headerStyle),
                                    ),
                                    Expanded(
                                      flex: 18,
                                      child: Text('Device Model',
                                          style: _headerStyle),
                                    ),
                                    Expanded(
                                      flex: 20,
                                      child: Text('Reported Time',
                                          style: _headerStyle),
                                    ),
                                    Expanded(
                                      flex: 12,
                                      child: Text('Status', style: _headerStyle),
                                    ),
                                  ],
                                ),
                              ),

                              // Table Data Rows
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: paginated.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(color: AppColors.divider, height: 1),
                                itemBuilder: (context, index) {
                                  final alert = paginated[index];
                                  final app = logic.getAppById(alert.appId);
                                  final appName = app?.name ?? 'App';
                                  final appPlatform = app?.platform ?? 'Unknown';

                                  return InkWell(
                                    onTap: () {
                                      context.go('/alerts/${alert.id}');
                                    },
                                    hoverColor: Colors.black.withOpacity(0.015),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 15),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 24,
                                            child: Text(
                                              alert.threatDisplayName,
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 12,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: SeverityChip(
                                                  severity:
                                                      alert.severity.label),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 18,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    appName,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color:
                                                          AppColors.textPrimary,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                PlatformBadge(
                                                    platform: appPlatform),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 18,
                                            child: Text(
                                              alert.deviceModel,
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 20,
                                            child: Text(
                                              alert.formattedReportedTime,
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 12,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: StatusBadge(
                                                  status: alert.status),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const Divider(color: AppColors.divider, height: 1),

                  // Pagination footer spanning 100% full width
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
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
                                  ? () =>
                                      context.read<AppLogic>().previousPage()
                                  : null,
                              icon: const Icon(Icons.chevron_left, size: 18),
                              label: const Text('Previous'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(
                                    color: AppColors.cardBorder),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton(
                              onPressed: logic.currentPage < logic.totalPages
                                  ? () => context.read<AppLogic>().nextPage()
                                  : null,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(
                                    color: AppColors.cardBorder),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
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
              style:
                  const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              icon: const Icon(Icons.arrow_drop_down,
                  color: AppColors.textSecondary),
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
              style:
                  const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              icon: const Icon(Icons.arrow_drop_down,
                  color: AppColors.textSecondary),
              items: const [
                DropdownMenuItem(value: 'ALL', child: Text('Severity: All')),
                DropdownMenuItem(value: 'High', child: Text('Severity: High')),
                DropdownMenuItem(
                    value: 'Medium', child: Text('Severity: Medium')),
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
              style:
                  const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              icon: const Icon(Icons.arrow_drop_down,
                  color: AppColors.textSecondary),
              items: const [
                DropdownMenuItem(value: 'ALL', child: Text('Status: All')),
                DropdownMenuItem(value: 'open', child: Text('Status: Open')),
                DropdownMenuItem(
                    value: 'resolved', child: Text('Status: Resolved')),
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
              style:
                  const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              icon: const Icon(Icons.arrow_drop_down,
                  color: AppColors.textSecondary),
              items: const [
                DropdownMenuItem(
                    value: 'NEWEST', child: Text('Sort: Newest first')),
                DropdownMenuItem(
                    value: 'SEVERITY',
                    child: Text('Sort: Severity (High → Low)')),
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

  Widget _buildDropdownContainer(
      {required String label, required Widget child}) {
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
