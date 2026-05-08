import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayssir/features/units/widgets/unit_circle_progress_widget.dart';
import 'package:tayssir/resources/colors/app_colors.dart';

class BayanProgressWidget extends StatelessWidget {
  const BayanProgressWidget({
    super.key,
    this.name,
    required this.upperText,
    required this.progress,
    this.direction = TextDirection.rtl,
    this.startColor = const Color(0xFF064E3B),
    this.endColor = const Color(0xFF059669),
    this.imageUrl = '',
  });

  final String? name;
  final String upperText;
  final double progress;
  final TextDirection direction;
  final Color startColor;
  final Color endColor;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final List<Color> gradientColors = isDark 
        ? [startColor, endColor]
        : [const Color(0xFF7C4A27), const Color(0xFF45220A)]; // Deeper bronze/brown

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(36.r),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(isDark ? 0.3 : 0.4),
            blurRadius: 25,
            spreadRadius: -2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern (Subtle)
          Positioned(
            left: -20, top: -20,
            child: Icon(Icons.star_outline_rounded, size: 100.sp, color: Colors.white.withOpacity(0.05)),
          ),
          
          Directionality(
            textDirection: direction,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Progress on the RIGHT
                Stack(
                  alignment: Alignment.center,
                  children: [
                    UnitCircleProgressWidget(
                      progress: progress,
                      size: 72,
                      borderWidth: 5,
                      padding: 0,
                      color: const Color(0xFFFBBF24), // Vibrant Gold
                    ),
                    Text(
                      '${progress.toInt()}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'SomarSans',
                      ),
                    ),
                  ],
                ),

                24.horizontalSpace,

                // 2. Text on the LEFT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        upperText,
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'SomarSans',
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (name != null && name!.isNotEmpty) ...[
                        6.verticalSpace,
                        Text(
                          name!.replaceAll('<br>', ' ').replaceAll('<br class="br-hide">', ' '),
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'SomarSans',
                          ),
                        ),
                      ],
                    ],
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
