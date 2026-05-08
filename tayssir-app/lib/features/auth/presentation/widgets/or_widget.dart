import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayssir/resources/colors/app_colors.dart';

class OrWidget extends StatelessWidget {
  const OrWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color lineColor = isDark ? const Color(0xFF334155) : AppColors.warmBorder;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Container(height: 1, color: lineColor)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'أو بالبريد الإلكتروني',
              style: TextStyle(
                color: isDark ? const Color(0xFF64748B) : AppColors.warmSubtitle,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'SomarSans',
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: lineColor)),
        ],
      ),
    );
  }
}
