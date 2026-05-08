import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/features/streaks/presentation/streak_notifier.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StreakWidget extends ConsumerWidget {
  const StreakWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakState = ref.watch(streakNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return streakState.when(
      data: (streak) {
        if (streak == null) return const SizedBox.shrink();
        final count = streak.currentStreak;
        
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)] 
                  : [Colors.white, AppColors.warmBackground],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.05) : AppColors.warmBorder,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withOpacity(isDark ? 0.1 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // Glowing Fire Icon
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 60.r,
                    height: 60.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF59E0B).withOpacity(0.1),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                   .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 2.seconds),
                  Text(
                    "🔥",
                    style: TextStyle(fontSize: 32.sp),
                  ),
                ],
              ),
              20.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "سلسلة النور",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.warmTitle,
                        fontFamily: 'SomarSans',
                      ),
                    ),
                    Text(
                      "أنت ملتزم لليوم الـ $count على التوالي",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isDark ? Colors.white70 : AppColors.warmSubtitle,
                        fontFamily: 'SomarSans',
                      ),
                    ),
                  ],
                ),
              ),
              // Streak Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Text(
                  "$count يوم",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
