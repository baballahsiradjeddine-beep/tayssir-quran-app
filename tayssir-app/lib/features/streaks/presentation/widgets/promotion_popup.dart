import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tayssir/common/app_buttons/big_button.dart';
import 'package:tayssir/router/app_router.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PromotionPopup extends StatelessWidget {
  const PromotionPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        width: 450.w,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(36.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36.r)),
                  child: Image.asset(
                    'assets/images/promo_final_review.png',
                    height: 240.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          (isDark ? const Color(0xFF0F172A) : Colors.white).withOpacity(0.2),
                          isDark ? const Color(0xFF0F172A) : Colors.white,
                        ],
                      ),
                    ),
                  ),
                ),
                // Close Button
                Positioned(
                  top: 16.h,
                  right: 16.w,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close_rounded, color: Colors.white, size: 20.sp),
                        ),
                      ),
                    ),
                  ),
                ),
                // Price Badge
                Positioned(
                  bottom: 10.h,
                  left: 24.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF28F3B), Color(0xFFE85D04)],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF28F3B).withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Text(
                      "1500 دج فقط",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'SomarSans',
                      ),
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                   .shimmer(duration: 2.seconds)
                   .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1.5.seconds),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(28.w, 10.h, 28.w, 32.h),
              child: Column(
                children: [
                  Text(
                    "تخفيض المراجعة النهائية! 🎓✨",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      fontFamily: 'SomarSans',
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                  
                  14.verticalSpace,
                  
                  Text(
                    "سارع في الاشتراك في تخفيض المراجعة النهائية بمبلغ 1500 دج فقط لفترة محدودة جداً! لا تفوت الفرصة للتفوق في البكالوريا.",
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                      fontFamily: 'SomarSans',
                      height: 1.6,
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                  
                  30.verticalSpace,
                  
                  BigButton(
                    text: "تم (سجل الآن) 🚀",
                    onPressed: () {
                      context.pop();
                      context.pushNamed(AppRoutes.subscriptionOptions.name);
                    },
                  ).animate()
                   .scale(delay: 600.ms, curve: Curves.elasticOut, duration: 1000.ms)
                   .shimmer(delay: 2.seconds, duration: 2.seconds),
                  
                  16.verticalSpace,
                  
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Text(
                      "ربما لاحقاً",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? Colors.white38 : Colors.grey.shade400,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SomarSans',
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ],
        ),
      ).animate().scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack, duration: 600.ms),
    );
  }
}
