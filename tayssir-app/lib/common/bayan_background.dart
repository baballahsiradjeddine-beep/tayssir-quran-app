import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/common/painters/islamic_pattern_painter.dart';

/// ويدجت [BayanBackground] يوفر خلفية هادئة ومنسابة تعزز تجربة المستخدم
/// وتضيف "بيان القرآن الرقمي" عبر تدرجات لونية متحركة ببطء تشبه حركة حبات السبحة.
/// تم تصميم هذا الـ Widget ليكون نظيفاً وسهل الاستخدام كحاوية (Wrapper) لأي شاشة.
class BayanBackground extends StatelessWidget {
  final Widget child;

  const BayanBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. التدرج اللوني الأساسي (حيادي متناسق مع السمة)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: Theme.of(context).brightness == Brightness.dark 
                  ? [
                      AppColors.darkColor,
                      AppColors.secondaryDark,
                    ]
                  : [
                      AppColors.surfaceWhite,
                      AppColors.scaffoldColor,
                    ],
              ),
            ),
          ),
          
          // 2. طبقة إضاءة ذهبية متحركة (نورانية)
          // هذه الطبقة تتحرك ببطء شديد لتقليل القلق البصري
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.goldColor.withOpacity(0.08),
                    Colors.transparent,
                  ],
                  center: Alignment.center,
                  radius: 1.2,
                ),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.2, 1.2),
              duration: 20.seconds,
              curve: Curves.easeInOut,
            )
            .blur(begin: const Offset(10, 10), end: const Offset(30, 30)),
          ),

          // 3. طبقة "الزخرفة الإسلامية" - نجوم ثمانية هادئة
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: IslamicPatternPainter(
                  opacity: 0.025, // Soft, barely visible watermark
                  spacing: 120.0, // Much more spaced out so it doesn't look cluttered
                  starRadius: 10.0, // Smaller stars
                  color: AppColors.goldColor,
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 15.seconds, color: Colors.white.withOpacity(0.05)),
            ),
          ),

          // 4. المحتوى الأساسي للشاشة
          SafeArea(child: child),
        ],
      ),
    );
  }
}
