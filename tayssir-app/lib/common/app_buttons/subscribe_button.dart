import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tayssir/debug/app_logger.dart';
import 'package:tayssir/providers/user/user_notifier.dart';
import 'package:tayssir/resources/resources.dart';
import 'package:tayssir/common/core/app_assets/dynamic_app_asset.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/common/painters/islamic_pattern_painter.dart';

import '../../router/app_router.dart';

class SubscribeButton extends ConsumerWidget {
  const SubscribeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userNotifierProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    void handlePress() {
      if (user != null && !user.isSub) {
        context.pushNamed(AppRoutes.subscriptionOptions.name);
        return;
      }
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald900.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: Stack(
          children: [
            // 1. Base Gradient Background (Deep & Rich)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.emerald950,
                      AppColors.emerald900,
                      AppColors.emerald800,
                    ],
                    stops: [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),

            // 2. Decorative Pattern (Arabic/Geometric Style)
            Positioned.fill(
              child: Opacity(
                opacity: 0.08,
                child: CustomPaint(
                  painter: IslamicPatternPainter(),
                ),
              ),
            ),

            // 3. Ambient Glows
            Positioned(
              top: -60.h,
              right: -40.w,
              child: Container(
                width: 180.r,
                height: 180.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold500.withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // 4. Content Row
            Padding(
              padding: EdgeInsets.all(20.r),
              child: Row(
                children: [
                  // Icon Section with Glow
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 70.r,
                        height: 70.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold500.withOpacity(0.2),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 58.r,
                        height: 58.r,
                        child: const DynamicAppAsset(
                          assetKey: 'quran_icon',
                          fallbackAssetPath: SVGs.icQuran,
                          type: AppAssetType.svg,
                        ).animate(onPlay: (c) => c.repeat(reverse: true))
                         .moveY(begin: -4, end: 4, duration: 2500.ms, curve: Curves.easeInOut),
                      ),
                    ],
                  ),
                  
                  18.horizontalSpace,
                  
                  // Text & Button Section
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: AppColors.gold500.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(color: AppColors.gold500.withOpacity(0.4), width: 0.5),
                              ),
                              child: Text(
                                'PREMIUM',
                                style: TextStyle(
                                  color: AppColors.gold200,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        6.verticalSpace,
                        Text(
                          'ساهم في وقف بيان القرآن واحصل على ميزات متقدمة لدعم رحلتك!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'SomarSans',
                            height: 1.3,
                          ),
                        ),
                        14.verticalSpace,
                        
                        // Premium Styled Button
                        GestureDetector(
                          onTap: () {
                            final email = ref.watch(userNotifierProvider).value?.email;
                            AppLogger.sendLog(
                              email: email ?? '',
                              content: 'Clicked on premium subscribe button',
                              type: LogType.subscriptions,
                            );
                            handlePress();
                          },
                          child: Container(
                            height: 38.h,
                            padding: EdgeInsets.symmetric(horizontal: 22.w),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.gold200, AppColors.gold500],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.gold600.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'اشترك الآن',
                                  style: TextStyle(
                                    color: AppColors.emerald950,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'SomarSans',
                                  ),
                                ),
                                8.horizontalSpace,
                                Icon(Icons.arrow_forward_rounded, color: AppColors.emerald950, size: 16.sp),
                              ],
                            ),
                          ),
                        ).animate(onPlay: (c) => c.repeat())
                         .shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.4))
                         .scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02), duration: 2.seconds, curve: Curves.easeInOut),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
