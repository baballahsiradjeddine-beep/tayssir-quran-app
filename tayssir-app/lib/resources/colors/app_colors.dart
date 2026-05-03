import 'package:flutter/material.dart';

class AppColors {
  // Brand Design Tokens
  AppColors._();

  // Core Brand Colors (Quranic Palette: Emerald & Gold)
  static const Color emerald50 = Color(0xFFECFDF5);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald700 = Color(0xFF047857); // Added missing token
  static const Color emerald800 = Color(0xFF064E3B);
  static const Color emerald900 = Color(0xFF064031);
  static const Color emerald950 = Color(0xFF022C22);

  static const Color gold200 = Color(0xFFFDE68A);
  static const Color gold500 = Color(0xFFF59E0B);
  static const Color gold600 = Color(0xFFD97706);

  static const Color primaryColor = emerald800;
  static const Color primaryColorLight = emerald50;
  static const Color secondaryColor = emerald600;
  static const Color goldColor = gold500;
  static const Color goldColorLight = gold200;
  
  // Background / Surface Colors
  static const Color scaffoldColor = Color(0xFFF1F5F9); // Slate-100 for better depth
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color darkColor = Color(0xFF0B1120);     // brand.darkSurface
  static const Color secondaryDark = Color(0xFF0F172A); // dark.bg

  // Accent Colors (Replaced Pink/Purple with Gold/Orange)
  static const Color accentColor = Color(0xFFF59E0B); // gold-500
  static const Color accentDark = Color(0xFFD97706);  // gold-600
  static const Color amberColor = Color(0xFFFBBF24);  // amber-400
  
  // Compatibility Aliases (pointing to new brand colors)
  static const Color pinkColor = accentColor;
  static const Color pinkDark = accentDark;
  static const Color purpleColor = amberColor;
  static const Color purpleDark = accentDark;
  
  // States
  static const Color greenColor = Color(0xFF10B981); // From arena_screen success
  static const Color redColor = Color(0xFFF43F5E);   // From arena_screen failure

  // Legacy / Basic
  static const Color textBlack = Color(0xFF0F172A); // Slate-900 for maximum contrast
  static const Color textBody = Color(0xFF334155);  // Slate-700 for better readability
  static const Color textWhite = Color(0xFFF8FAFC);
  static const Color greyColor = Color(0xFF64748B); // Slate-500
  static const Color borderColor = Color(0xFFE2E8F0); // Slate-200
  static const Color shadowColor = Color(0x1A0F172A); // Subtle Slate shadow for light mode

  // Specific UI Elements (Legacy/Compatibility)
  static const Color disabledTextColor = Color(0xFF94A3B8); // Slate-400
  static const Color videoControls = Color(0xB30F172A);    // 70% opacity dark
  static const Color darkBlue = Color(0xFF1E293B);          // Brand dark

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryColor, secondaryColor],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold200, gold500],
  );

  // Compatibility Gradients
  static const LinearGradient purpleGradient = accentGradient;
  static const LinearGradient pinkGradient = accentGradient;
}
