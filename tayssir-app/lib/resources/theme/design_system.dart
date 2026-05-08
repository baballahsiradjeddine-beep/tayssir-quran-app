import 'package:flutter/material.dart';
import 'package:tayssir/resources/colors/app_colors.dart';

class DesignSystem {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;

  DesignSystem({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
  });

  // Default Quranic Style (The one we just finished)
  factory DesignSystem.quranicLight() {
    return DesignSystem(
      primary: AppColors.emerald800,
      secondary: AppColors.emerald600,
      accent: const Color(0xFFD97706), // Gold
      background: AppColors.warmBackground,
      surface: Colors.white,
      textPrimary: AppColors.emerald900,
      textSecondary: AppColors.emerald700,
    );
  }

  factory DesignSystem.quranicDark() {
    return DesignSystem(
      primary: const Color(0xFF10B981), // Emerald bright
      secondary: const Color(0xFF059669),
      accent: const Color(0xFFF59E0B), // Gold bright
      background: const Color(0xFF0F172A), // Deep Slate
      surface: const Color(0xFF1E293B), // Slate
      textPrimary: Colors.white,
      textSecondary: Colors.white.withOpacity(0.7),
    );
  }

  factory DesignSystem.fromJson(Map<String, dynamic> json) {
    return DesignSystem(
      primary: _parseColor(json['primary']),
      secondary: _parseColor(json['secondary']),
      accent: _parseColor(json['accent']),
      background: _parseColor(json['background']),
      surface: _parseColor(json['surface']),
      textPrimary: _parseColor(json['text_primary']),
      textSecondary: _parseColor(json['text_secondary']),
    );
  }

  static Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  DesignSystem copyWith({
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
  }) {
    return DesignSystem(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }
}

extension DesignSystemExtension on BuildContext {
  DesignSystem get ds {
    final theme = Theme.of(this);
    final isDark = theme.brightness == Brightness.dark;
    
    return DesignSystem(
      primary: theme.colorScheme.primary,
      secondary: theme.colorScheme.secondary,
      accent: theme.colorScheme.tertiary,
      background: theme.scaffoldBackgroundColor,
      surface: theme.cardTheme.color ?? theme.colorScheme.surface,
      textPrimary: theme.textTheme.titleLarge?.color ?? Colors.black,
      textSecondary: theme.textTheme.bodyMedium?.color ?? Colors.grey,
    );
  }
}
