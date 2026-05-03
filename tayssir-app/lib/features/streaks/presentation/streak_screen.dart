import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tayssir/common/app_buttons/big_button.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/features/streaks/data/streak_model.dart';
import 'package:tayssir/features/streaks/utils/streak_share_utils.dart';
import 'package:tayssir/router/app_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/services/sounds/sound_manager.dart';
import 'package:tayssir/providers/special_effect/special_effect_provider.dart';
import 'package:tayssir/providers/data/data_provider.dart';
import 'package:tayssir/features/streaks/presentation/widgets/promotion_popup.dart';
import 'package:tayssir/providers/settings/settings_provider.dart';
import 'package:tayssir/providers/user/user_notifier.dart';

class StreakScreen extends HookConsumerWidget {
  final StreakModel streak;
  final int unitId;

  const StreakScreen({super.key, required this.streak, required this.unitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int currentStreak = streak.currentStreak;
    final int weekNumber = (currentStreak > 0) ? (currentStreak - 1) ~/ 7 : 0;
    final int weekStartDay = (weekNumber * 7) + 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSoundOn = ref.watch(isSoundEnabledProvider);

    useEffect(() {
      if (isSoundOn) {
        SoundService.playStreak();
      }

      // Show promotion popup if not shown today and user is NOT subscribed
      Future.delayed(const Duration(milliseconds: 2500), () async {
        try {
          final user = ref.read(userNotifierProvider).valueOrNull;
          final isSubscribed = user?.isSub ?? false;

          // If already subscribed, don't show the promotion
          if (isSubscribed) return;

          final prefs = ref.read(sharedPreferencesProvider).value;
          if (prefs == null) return;

          final lastShown = prefs.getString('promo_final_review_last_shown');
          final today = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD

          if (lastShown != today) {
            if (context.mounted) {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => const PromotionPopup(),
              );
              await prefs.setString('promo_final_review_last_shown', today);
            }
          }
        } catch (e) {
          // Ignore errors
        }
      });

      return null;
    }, []);

    return AppScaffold(
      onPopScope: () {},
      paddingX: 0,
      paddingY: 0,
      bodyBackgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.scaffoldColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 800;

          return Stack(
            children: [
                // Ambient Orange Glow
                Positioned(
                  top: -150.h,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 400.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFF28F3B).withOpacity(0.12),
                          const Color(0xFFF28F3B).withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1150),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60.w : 24.w),
                        child: Column(
                          children: [
                            20.verticalSpace,
                            
                            // Header Section
                            Text(
                              "مبارك لك 🎉",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24.sp,
                                color: const Color(0xFFF28F3B),
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SomarSans',
                              ),
                            ).animate().fadeIn().slideY(begin: -0.2, end: 0),
                            12.verticalSpace,
                            Text(
                              "$currentStreak أيام متواصلة",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isDesktop ? 48.sp : 36.sp,
                                color: const Color(0xFFF28F3B),
                                fontWeight: FontWeight.w900,
                                fontFamily: 'SomarSans',
                                height: 1.2,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFFF28F3B).withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              ),
                            ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.1, end: 0),

                            const Spacer(flex: 2),

                            // Fire Section
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: isDesktop ? 180.w : 140.w,
                                  height: isDesktop ? 180.w : 140.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        const Color(0xFFF28F3B).withOpacity(0.35),
                                        const Color(0xFFF28F3B).withOpacity(0.0),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: isDesktop ? 130.w : 100.w,
                                  height: isDesktop ? 130.w : 100.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFF28F3B).withOpacity(0.1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFF28F3B).withOpacity(0.2),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      )
                                    ]
                                  ),
                                  child: Center(
                                    child: Text(
                                      "🔥",
                                      style: TextStyle(fontSize: isDesktop ? 80.sp : 54.sp),
                                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                                     .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 1.seconds)
                                     .shimmer(delay: 2.seconds, duration: 1.5.seconds),
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut, duration: 1.seconds),

                            const Spacer(flex: 3),

                            // Streak Calendar Card
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 800),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : AppColors.surfaceWhite,
                                    borderRadius: BorderRadius.circular(32.r),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9), 
                                      width: 1.5
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                                        blurRadius: 25,
                                        offset: const Offset(0, 15),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: List.generate(7, (index) {
                                              final dayNumber = weekStartDay + index;
                                              final bool isCompleted = dayNumber <= currentStreak;
                                              return Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                                child: _buildNumericDayItem(dayNumber, isCompleted, isDark)
                                                    .animate()
                                                    .fadeIn(delay: (600 + index * 100).ms)
                                                    .scale(begin: const Offset(0.8, 0.8)),
                                              );
                                            }),
                                          ),
                                        ),
                                      ),
                                      16.verticalSpace,
                                      Divider(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                                      16.verticalSpace,
                                      Text(
                                        "استمر في العطاء، فكل خطوة صغيرة تقربك من القمة! 🚀",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          color: isDark ? Colors.white70 : AppColors.textBlack,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'SomarSans',
                                          height: 1.5,
                                        ),
                                      ).animate().fadeIn(delay: 1.5.seconds),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const Spacer(flex: 3),

                            // Footer Section
                            Text(
                              "لا تتوقف... كل يوم يصنع فارقاً!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF059669),
                                fontWeight: FontWeight.w900,
                                fontFamily: 'SomarSans',
                              ),
                            ),

                            32.verticalSpace,

                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 800),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: BigButton(
                                        text: "تابع",
                                        buttonType: ButtonType.secondary,
                                        onPressed: () {
                                          final units = ref.read(dataProvider).contentData.units;
                                          final unit = units.firstWhere((u) => u.id == unitId);
                                          final courseId = unit.materialId;
                                          
                                          context.pushReplacementNamed(
                                            AppRoutes.chapters.name,
                                            pathParameters: {
                                              'courseId': courseId.toString(),
                                              'unitId': unitId.toString(),
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    20.horizontalSpace,
                                    Expanded(
                                      child: BigButton(
                                        text: "مشاركة",
                                        buttonType: ButtonType.primary,
                                        onPressed: () {
                                          StreakShareUtils.shareStreak(context, streak);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            20.verticalSpace,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildNumericDayItem(int dayNumber, bool isCompleted, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "$dayNumber",
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.white38 : AppColors.textBody.withOpacity(0.6),
            fontWeight: FontWeight.bold,
            fontFamily: 'SomarSans',
          ),
        ),
        10.verticalSpace,
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: isCompleted ? const Color(0xFFF28F3B) : (isDark ? const Color(0xFF0F172A) : Colors.white),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isCompleted 
                  ? const Color(0xFFF28F3B) 
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              width: 2,
            ),
            boxShadow: [
              if (isCompleted)
                BoxShadow(
                  color: const Color(0xFFF28F3B).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
            ]
          ),
          child: isCompleted
              ? Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 24.sp,
                )
              : null,
        ),
      ],
    );
  }
}
