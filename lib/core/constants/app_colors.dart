// File: lib/core/constants/app_colors.dart
// Purpose: Color palette sampled directly from the client's screenshots. No invented colors.
// Used by: core/theme/* and feature widgets.

import 'package:flutter/material.dart';

class AppColors {
  // Brand / CTA — the dominant yellow used on Login button, Set MPIN dots, Claim Now,
  // Today's Task banner, active bottom-nav, and the floating + icon.
  static const Color primary = Color(0xFFFFB300);
  static const Color primaryDark = Color(0xFFF5A300);
  static const Color primarySoft = Color(0xFFFFF3D6); // pill backgrounds, soft accents
  static const Color avatarBg = Color(0xFFFFEFD6);    // labour avatar circle background
  /// Softer yellow used specifically on the dashboard's TODAY'S TASK banner —
  /// the client picked this shade in the latest review pass.
  static const Color todaysTaskBg = Color(0xFFFFDB6B);

  // Surfaces
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Colors.white;
  static const Color cardBorder = Color(0xFFEAECEF);

  // Status
  static const Color success = Color(0xFF4CAF50); // welcome shield green
  static const Color info = Color(0xFF1F6FEB);    // "45/55 Today Attendance" blue
  static const Color warning = Color(0xFFFFB300); // matches primary
  static const Color error = Color(0xFFE53935);

  // Dividers / outlines
  static const Color divider = Color(0xFFE5E7EB);

  // Text
  static const Color textPrimary = Color(0xFF1A1F2C);   // dark navy/black titles
  static const Color textSecondary = Color(0xFF6B7280); // captions / subtitles
  static const Color textDisabled = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFF1A1F2C); // dark text on yellow buttons
}
