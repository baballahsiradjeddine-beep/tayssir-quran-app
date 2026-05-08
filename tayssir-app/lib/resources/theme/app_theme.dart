import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/resources/theme/design_system.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData theme(DesignSystem ds, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      fontFamily: 'SomarSans',
      scaffoldBackgroundColor: ds.background,
      brightness: brightness,
      shadowColor: AppColors.shadowColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ds.primary,
        primary: ds.primary,
        secondary: ds.secondary,
        tertiary: ds.accent,
        surface: ds.surface,
        onSurface: isDark ? Colors.white : AppColors.textBlack,
        outline: AppColors.borderColor,
        brightness: brightness,
      ),
      cardTheme: CardThemeData(
        elevation: isDark ? 0 : 2,
        shadowColor: AppColors.shadowColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        color: ds.surface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.textBlack),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      textTheme: _textTheme(ds, brightness),
    );
  }

  static TextTheme _textTheme(DesignSystem ds, Brightness brightness) {
    final headerColor = ds.textPrimary;
    final bodyColor = ds.textSecondary;

    return TextTheme(
      displayLarge: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w900, color: headerColor, letterSpacing: -0.5, fontFamily: 'SomarSans'),
      displayMedium: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: headerColor, letterSpacing: -0.5, fontFamily: 'SomarSans'),
      displaySmall: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: headerColor, fontFamily: 'SomarSans'),
      headlineMedium: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: headerColor, fontFamily: 'SomarSans'),
      titleLarge: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: headerColor, fontFamily: 'SomarSans'),
      titleMedium: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: headerColor, fontFamily: 'SomarSans'),
      bodyLarge: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: bodyColor, fontFamily: 'SomarSans'),
      bodyMedium: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.normal, color: bodyColor, fontFamily: 'SomarSans'),
      labelSmall: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: bodyColor, fontFamily: 'SomarSans'),
    );
  }
}
