import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/features/units/widgets/unit_circle_progress_widget.dart';
import 'package:tayssir/providers/data/data_provider.dart';
import 'package:tayssir/providers/user/user_notifier.dart';
import 'package:tayssir/common/painters/islamic_pattern_painter.dart';
import 'package:tayssir/resources/colors/app_colors.dart';

class UserProgressWidget extends StatelessWidget {
  const UserProgressWidget({
    super.key,
    // required this.courses,
  });

  // final List<MaterialModel> courses;

// // Helper method to create stat items
//   Widget _buildStatItem(
//       {required IconData icon, required String value, required String label}) {
//     return Column(
//       children: [
//         Icon(
//           icon,
//           color: AppColors.primaryColor,
//           size: 22.w,
//         ),
//         6.verticalSpace,
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 16.sp,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         4.verticalSpace,
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12.sp,
//             color: Colors.grey.shade600,
//           ),
//         ),
//       ],
//     );
//   }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        // final totalCourses = courses.length;
        // final completedCourses =
        // courses.where((course) => course.progress == 100).length;
        // final progress =
        // totalCourses > 0 ? (completedCourses / totalCourses) : 0.0;
        final totalChapters = ref.watch(dataProvider).totalChapters;
        final completedChapters = ref.watch(dataProvider).completedChapters;
        final progress =
            totalChapters > 0 ? (completedChapters / totalChapters) : 0.0;
        final userPoints =
            ref.watch(userNotifierProvider).valueOrNull?.points ?? 0;

        final bool isDesktop = MediaQuery.sizeOf(context).width > 800;

        final bool isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          width: double.infinity,
          height: isDesktop ? 135.h : 120.h,
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(
          gradient: isDark 
              ? const LinearGradient(
                  colors: [Color(0xFF064E3B), Color(0xFF065F46)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFB45309), Color(0xFF7C4A27)], // Bronze → Brown
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
            borderRadius: BorderRadius.circular(32.r),
            border: null,
            boxShadow: [
              BoxShadow(
                color: isDark 
                  ? const Color(0xFF064E3B).withOpacity(0.3) 
                  : const Color(0xFFB45309).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Dot Pattern
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: CustomPaint(
                    painter: IslamicPatternPainter(
                      color: Colors.white,
                      opacity: 0.15,
                      spacing: 40.0,
                      starRadius: 12.0,
                    ),
                  ),
                ),
              ),
              
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40.w : 24.w, vertical: 10.h),
                child: Row(
                  children: [
                    // 1. Progress Circle
                    Container(
                      padding: EdgeInsets.all(isDesktop ? 8.w : 4.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      child: UnitCircleProgressWidget(
                        progress: progress * 100,
                        size: isDesktop ? 80.w : 60.w,
                        borderWidth: isDesktop ? 8.w : 5.w,
                        padding: 0,
                        color: const Color(0xFFF59E0B), // Gold Progress
                      ),
                    ),

                    if (isDesktop) const Spacer(),
                    if (!isDesktop) 16.horizontalSpace,

                    // 2. Middle Stats (Desktop Only focus)
                    if (isDesktop)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              _buildStatBadge(Icons.auto_stories_rounded, '$completedChapters / $totalChapters', 'سورة', isDark),
                              20.horizontalSpace,
                              _buildStatBadge(Icons.stars_rounded, '$userPoints', 'نقطة ولاية', isDark),
                            ],
                          ),
                        ],
                      ),

                    if (isDesktop) const Spacer(),

                    // 3. Info text
                    Expanded(
                      flex: isDesktop ? 0 : 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'السور المتممة',
                            style: TextStyle(
                              fontSize: isDesktop ? 22.sp : 15.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontFamily: 'SomarSans', // Use Cairo for titles
                            ),
                          ),
                          4.verticalSpace,
                          if (!isDesktop)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.auto_stories_rounded, color: Colors.white, size: 16.w),
                                  8.horizontalSpace,
                                  Text(
                                    '$completedChapters / $totalChapters',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          4.verticalSpace,
                          Text(
                            'ارتقِ في درجات الولاية ✨',
                            style: TextStyle(
                              fontSize: isDesktop ? 14.sp : 10.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatBadge(IconData icon, String value, String unit, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.15) : AppColors.warmBorder.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : AppColors.warmBorder, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.white : AppColors.warmTitle, size: 24.w),
          12.horizontalSpace,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.warmTitle,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'SomarSans',
                ),
              ),
              Text(
                unit,
                style: TextStyle(
                  color: isDark ? Colors.white.withOpacity(0.7) : AppColors.warmSubtitle,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SomarSans',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
