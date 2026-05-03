import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tayssir/resources/colors/app_colors.dart';

class ResultStatsWidget extends StatelessWidget {
  const ResultStatsWidget({
    super.key,
    required this.value,
    required this.title,
    required this.icon,
    this.startColor = AppColors.primaryColor,
    this.endColor = const Color(0xff0080FF),
  });

  final String value;
  final String title;
  final String icon;
  final Color startColor;
  final Color endColor;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: startColor.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(isDark ? 0.15 : 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [startColor, endColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontFamily: 'SomarSans',
              ),
            ),
          ),
          
          // Body
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (title.contains('الدقة') || title.contains('وقت') || title.contains('الوقت'))
                  SvgPicture.asset(
                    icon,
                    height: 18.sp,
                    width: 18.sp,
                    colorFilter: ColorFilter.mode(startColor, BlendMode.srcIn),
                  )
                else
                  Icon(
                    Icons.check_circle,
                    color: startColor,
                    size: 20.sp,
                  ),
                8.horizontalSpace,
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22.sp,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontWeight: FontWeight.w900,
                    fontFamily: 'SomarSans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
