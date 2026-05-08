import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayssir/resources/colors/app_colors.dart';

class VisualProgressMap extends StatelessWidget {
  final int completedJuz; // For now a simple count, can be complex list
  final bool isDark;

  const VisualProgressMap({
    super.key,
    required this.completedJuz,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10.w, bottom: 15.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "خريطة الإنجاز النورانية 🗺️",
                style: TextStyle(
                  fontFamily: 'SomarSans',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.warmTitle,
                ),
              ),
              Text(
                "$completedJuz / 30 جزء",
                style: TextStyle(
                  fontFamily: 'SomarSans',
                  fontSize: 12.sp,
                  color: AppColors.goldColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 30,
            reverse: true, // Arabic direction
            itemBuilder: (context, index) {
              final juzNum = index + 1;
              final isCompleted = juzNum <= completedJuz;
              
              return Container(
                width: 70.w,
                margin: EdgeInsets.only(left: 12.w),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow Effect for completed
                        if (isCompleted)
                          Container(
                            width: 55.w,
                            height: 55.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.goldColor.withOpacity(0.4),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                           .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 2.seconds),
                        
                        Container(
                          width: 50.w,
                          height: 50.w,
                          decoration: BoxDecoration(
                            color: isCompleted 
                              ? AppColors.goldColor 
                              : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCompleted 
                                ? Colors.white.withOpacity(0.5) 
                                : AppColors.goldColor.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "$juzNum",
                              style: TextStyle(
                                fontFamily: 'SomarSans',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w900,
                                color: isCompleted ? Colors.white : (isDark ? Colors.white38 : AppColors.warmSubtitle),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    8.verticalSpace,
                    Text(
                      "جزء $juzNum",
                      style: TextStyle(
                        fontFamily: 'SomarSans',
                        fontSize: 10.sp,
                        color: isCompleted ? AppColors.goldColor : (isDark ? Colors.white24 : Colors.grey),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
