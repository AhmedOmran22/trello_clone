import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand Colors (Trello-inspired) ──
  static const Color primary = Color(0xFF0079BF);
  static const Color primaryDark = Color(0xFF026AA7);
  static const Color primaryLight = Color(0xFF5BA4CF);

  // ── Background Colors ──
  static const Color backgroundLight = Color(0xFFF4F5F7);
  static const Color backgroundDark = Color(0xFF1D2125);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF282E33);

  // ── Text Colors ──
  static const Color textPrimaryLight = Color(0xFF172B4D);
  static const Color textSecondaryLight = Color(0xFF5E6C84);
  static const Color textPrimaryDark = Color(0xFFB6C2CF);
  static const Color textSecondaryDark = Color(0xFF8C9BAB);

  // ── Priority Colors (for task cards) ──
  static const Color priorityUrgent = Color(0xFFEB5A46);
  static const Color priorityHigh = Color(0xFFF2D600);
  static const Color priorityMedium = Color(0xFF00C2E0);
  static const Color priorityLow = Color(0xFF61BD4F);

  // ── Utility Colors ──
  static const Color divider = Color(0xFFDFE1E6);
  static const Color error = Color(0xFFEB5A46);
  static const Color success = Color(0xFF61BD4F);
}