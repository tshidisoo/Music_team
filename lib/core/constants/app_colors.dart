import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF6C3FE8);
  static const Color primaryLight = Color(0xFF9B75F5);
  static const Color primaryDark = Color(0xFF4A25B8);

  // Secondary / accent
  static const Color secondary = Color(0xFFFF8C00);
  static const Color secondaryLight = Color(0xFFFFAD40);
  static const Color secondaryDark = Color(0xFFCC7000);

  // Backgrounds
  static const Color backgroundLight = Color(0xFFF8F6FF);
  static const Color backgroundDark = Color(0xFF1A1040);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2A1F5C);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF251848);

  // Text
  static const Color textPrimaryLight = Color(0xFF1A1040);
  static const Color textPrimaryDark = Color(0xFFF0EEFF);
  static const Color textSecondaryLight = Color(0xFF6B6B8A);
  static const Color textSecondaryDark = Color(0xFFB0A8D8);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // XP / Gamification
  static const Color xpGold = Color(0xFFFFD700);
  static const Color xpBar = Color(0xFF6C3FE8);
  static const Color streakOrange = Color(0xFFFF6B35);
  static const Color badgeGold = Color(0xFFFFB800);
  static const Color badgeSilver = Color(0xFFC0C0C0);
  static const Color badgeBronze = Color(0xFFCD7F32);

  // Level colors
  static const Color levelNovice = Color(0xFF94A3B8);
  static const Color levelApprentice = Color(0xFF22C55E);
  static const Color levelStudent = Color(0xFF3B82F6);
  static const Color levelMusician = Color(0xFF8B5CF6);
  static const Color levelMaestro = Color(0xFFFFD700);

  // Gradient presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C3FE8), Color(0xFF9B75F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFF8C00), Color(0xFFFFAD40)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF4A25B8), Color(0xFF6C3FE8), Color(0xFF9B75F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
