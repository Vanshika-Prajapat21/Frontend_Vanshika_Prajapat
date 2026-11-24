import 'package:flutter/material.dart';

/// Cohesive color palette matching the Bugsmirror dashboard design.
class AppColors {
  // Shell & Layout
  static const Color sidebarBg = Color(0xFF232B38);
  static const Color sidebarActive = Color(0xFF313B4D);
  static const Color sidebarText = Color(0xFF94A3B8);
  static const Color sidebarTextActive = Color(0xFFFFFFFF);
  
  static const Color background = Color(0xFFFBF9F7);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFEAE7E2);
  static const Color divider = Color(0xFFEEEEEE);

  // Typography
  static const Color textPrimary = Color(0xFF1E2530);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Buttons & Accents
  static const Color brandBlue = Color(0xFF2563EB);
  static const Color buttonDark = Color(0xFF232B38);
  static const Color buttonDarkHover = Color(0xFF1B222D);

  // Severity indicator colors (per task spec: High red, Medium orange, Low grey)
  static const Color severityHigh = Color(0xFFD9383A);
  static const Color severityMedium = Color(0xFFF57C00);
  static const Color severityLow = Color(0xFF757575);

  // Status badges
  static const Color statusOpenBg = Color(0xFFE8F5E9);
  static const Color statusOpenText = Color(0xFF2E7D32);
  static const Color statusResolvedBg = Color(0xFFF3F4F6);
  static const Color statusResolvedText = Color(0xFF6B7280);

  // Platform badges
  static const Color platformBadgeBg = Color(0xFFF3F4F6);
  static const Color platformBadgeBorder = Color(0xFFE5E7EB);
  static const Color platformBadgeText = Color(0xFF4B5563);
}

/// Spacing and sizing layout constants
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double sidebarWidth = 220.0;
}
