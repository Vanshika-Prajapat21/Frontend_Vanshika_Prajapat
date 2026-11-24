import 'package:flutter/material.dart';
import '../constants.dart';

/// Application shell providing the dark sidebar and responsive navigation
class AppShell extends StatelessWidget {
  final String activeRoute; // 'dashboard' or 'alerts'
  final Widget child;
  final VoidCallback onSelectDashboard;
  final VoidCallback onSelectAlerts;

  const AppShell({
    super.key,
    required this.activeRoute,
    required this.child,
    required this.onSelectDashboard,
    required this.onSelectAlerts,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 850;

        if (isNarrow) {
          // Mobile / Narrow screen layout (< 850px) with clean AppBar & Drawer
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.sidebarBg,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.brandBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.security, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Bugsmirror',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            drawer: Drawer(
              backgroundColor: AppColors.sidebarBg,
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.brandBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.security, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Bugsmirror',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildNavItem(
                      icon: Icons.dashboard_rounded,
                      label: 'Dashboard',
                      isActive: activeRoute == 'dashboard',
                      onTap: () {
                        Navigator.pop(context);
                        onSelectDashboard();
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildNavItem(
                      icon: Icons.notifications_none_rounded,
                      label: 'Alerts',
                      isActive: activeRoute == 'alerts',
                      onTap: () {
                        Navigator.pop(context);
                        onSelectAlerts();
                      },
                    ),
                  ],
                ),
              ),
            ),
            body: child,
          );
        }

        // Desktop / Wide layout with permanent left sidebar
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Row(
            children: [
              // Sidebar
              Container(
                width: AppSpacing.sidebarWidth,
                color: AppColors.sidebarBg,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bugsmirror Logo
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 32.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.brandBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.security, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Bugsmirror',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Navigation items
                    _buildNavItem(
                      icon: Icons.dashboard_rounded,
                      label: 'Dashboard',
                      isActive: activeRoute == 'dashboard',
                      onTap: onSelectDashboard,
                    ),
                    const SizedBox(height: 8),
                    _buildNavItem(
                      icon: Icons.notifications_none_rounded,
                      label: 'Alerts',
                      isActive: activeRoute == 'alerts',
                      onTap: onSelectAlerts,
                    ),
                  ],
                ),
              ),

              // Main page content
              Expanded(
                child: child,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.sidebarActive : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.sidebarTextActive : AppColors.sidebarText,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.sidebarTextActive : AppColors.sidebarText,
                fontSize: 15,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
