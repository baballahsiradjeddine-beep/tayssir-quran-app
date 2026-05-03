import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayssir/features/units/widgets/unit_circle_progress_widget.dart';

class TayssirProgressWidget extends StatelessWidget {
  const TayssirProgressWidget({
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Progress on the RIGHT
            UnitCircleProgressWidget(
              progress: progress,
              size: 60,
              borderWidth: 4,
              padding: 0,
              color: const Color(0xFFF59E0B), // Gold Progress
            ),

            20.horizontalSpace,

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
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'SomarSans',
                      height: 1.1,
                    ),
                  ),
                  if (name != null && name!.isNotEmpty) ...[
                    4.verticalSpace,
                    Text(
                      name!.replaceAll('<br>', ' ').replaceAll('<br class="br-hide">', ' '),
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
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
    );
  }
}
