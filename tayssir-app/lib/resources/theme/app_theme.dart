import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        fontFamily: 'SomarSans',
        scaffoldBackgroundColor: AppColors.scaffoldColor,
        brightness: Brightness.light,
        shadowColor: AppColors.shadowColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryColor,
          primary: AppColors.primaryColor,
          secondary: AppColors.secondaryColor,
          tertiary: AppColors.goldColor,
          surface: AppColors.surfaceWhite,
          onSurface: AppColors.textBlack,
          outline: AppColors.borderColor,
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: AppColors.shadowColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          color: AppColors.surfaceWhite,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.textBlack),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),
        textTheme: _textTheme(Brightness.light),
      );

  static ThemeData get darkTheme => ThemeData(
        fontFamily: 'SomarSans',
        scaffoldBackgroundColor: AppColors.darkColor,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryColor,
          primary: AppColors.primaryColor,
          secondary: AppColors.secondaryColor,
          tertiary: AppColors.goldColor,
          surface: AppColors.secondaryDark,
          onSurface: Colors.white,
          brightness: Brightness.dark,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          color: AppColors.secondaryDark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
        textTheme: _textTheme(Brightness.dark),
      );

  static TextTheme _textTheme(Brightness brightness) {
    final headerColor = brightness == Brightness.light ? AppColors.primaryColor : Colors.white;
    final bodyColor = brightness == Brightness.light ? AppColors.textBody : Colors.white.withOpacity(0.9);

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
