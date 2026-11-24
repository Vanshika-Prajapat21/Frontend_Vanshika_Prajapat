import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../logic/app_logic.dart';
import '../widgets/platform_badge.dart';
import '../widgets/summary_card.dart';

/// Screen 1: Dashboard (Home page)
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = context.watch<AppLogic>();

    if (logic.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.brandBlue),
            SizedBox(height: 16),
            Text(
              'Loading security alerts...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (logic.errorMessage != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.severityHigh, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Failed to Load Data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                logic.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.read<AppLogic>().loadAlertsData(),
                icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                label: const Text('Retry', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonDark,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Title
              const Text(
                'Security Alerts Dashboard',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 28),

              // Three Summary Cards Row
              _buildSummaryCards(logic, constraints.maxWidth),

              const SizedBox(height: 32),

              // Apps Card Container
              _buildAppsSection(context, logic),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(AppLogic logic, double availableWidth) {
    final card1 = SummaryCard(
      title: 'Total Alerts',
      count: logic.totalAlertsCount,
      icon: const Icon(
        Icons.notifications_none_rounded,
        color: AppColors.textMuted,
        size: 22,
      ),
    );

    final card2 = SummaryCard(
      title: 'Open Alerts',
      count: logic.openAlertsCount,
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: AppColors.textMuted,
        size: 22,
      ),
    );

    final card3 = SummaryCard(
      title: 'High Severity Open',
      count: logic.highSeverityOpenAlertsCount,
      icon: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          color: AppColors.severityHigh,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.priority_high_rounded,
          color: Colors.white,
          size: 16,
        ),
      ),
    );

    if (availableWidth < 700) {
      return Column(
        children: [
          card1,
          const SizedBox(height: 16),
          card2,
          const SizedBox(height: 16),
          card3,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: card1),
        const SizedBox(width: 20),
        Expanded(child: card2),
        const SizedBox(width: 20),
        Expanded(child: card3),
      ],
    );
  }

  Widget _buildAppsSection(BuildContext context, AppLogic logic) {
    return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Apps',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Apps sending security alerts',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: logic.apps.length,
            separatorBuilder: (_, __) => const Divider(color: AppColors.divider, height: 1),
            itemBuilder: (context, index) {
              final app = logic.apps[index];
              final openAlertCount = logic.getOpenAlertsCountForApp(app.id);

              return InkWell(
                onTap: () {
                  context.read<AppLogic>().updateFilter(appId: app.id);
                  context.go('/alerts');
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                  child: Row(
                    children: [
                      Text(
                        app.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      PlatformBadge(platform: app.platform),
                      const Spacer(),
                      Text(
                        '$openAlertCount ${openAlertCount == 1 ? "open alert" : "open alerts"}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
