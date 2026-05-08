import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayssir/features/challanges/utils/prayer_times_helper.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FlashChallengeWidget extends StatelessWidget {
  const FlashChallengeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isActive = PrayerTimesHelper.isFlashChallengeActive();
    final nextTime = PrayerTimesHelper.getNextFlashTime();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive 
              ? [const Color(0xFF7C3AED), const Color(0xFF4F46E5)] 
              : (isDark ? [const Color(0xFF1E293B), const Color(0xFF1E293B)] : [Colors.grey.shade100, Colors.grey.shade200]),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ] : null,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50.r,
            height: 50.r,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isActive ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive ? Icons.bolt_rounded : Icons.timer_outlined,
              color: isActive ? Colors.white : Colors.grey,
              size: 30.sp,
            ),
          ).animate(target: isActive ? 1 : 0)
           .shimmer(duration: 2.seconds, color: Colors.white24),
          20.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "تحدي الوميض",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: isActive ? Colors.white : Colors.grey,
                    fontFamily: 'SomarSans',
                  ),
                ),
                Text(
                  isActive 
                      ? "التحدي متاح الآن! نقاط مضاعفة" 
                      : "التحدي القادم: $nextTime",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isActive ? Colors.white.withOpacity(0.8) : Colors.grey,
                    fontFamily: 'SomarSans',
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            ElevatedButton(
              onPressed: () {}, // Handle navigation to flash challenge
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF7C3AED),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
              ),
              child: Text(
                "ابدأ الآن",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp),
              ),
            ),
        ],
      ),
    );
  }
}
