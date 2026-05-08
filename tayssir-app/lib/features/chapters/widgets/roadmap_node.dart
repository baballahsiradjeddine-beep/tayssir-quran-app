import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tayssir/resources/colors/app_colors.dart';

class RoadmapNode extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final double progress;
  final bool isLocked;
  final bool isCurrent;
  final bool isPremium;
  final VoidCallback? onTap;
  final Color startColor;
  final Color endColor;

  const RoadmapNode({
    super.key,
    required this.title,
    this.imageUrl,
    required this.progress,
    required this.isLocked,
    required this.isCurrent,
    required this.isPremium,
    this.onTap,
    required this.startColor,
    required this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isCompleted = progress >= 1.0;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer Ring / Glow
              if (isCurrent)
                Container(
                  width: 90.sp,
                  height: 90.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? startColor : AppColors.warmTitle).withOpacity(isDark ? 0.3 : 0.15),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1500.ms, curve: Curves.easeInOut),

              // Progress Border
              Container(
                width: 75.sp,
                height: 75.sp,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isLocked 
                        ? (isDark ? Colors.white10 : Colors.black12)
                        : (isCompleted ? Colors.green : Colors.transparent),
                    width: 3,
                  ),
                ),
                child: isLocked || isCompleted 
                    ? null 
                    : CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 4,
                        backgroundColor: isDark ? Colors.white10 : AppColors.warmTitle.withOpacity(0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(isDark ? startColor : AppColors.warmTitle),
                      ),
              ),

              // Main Node Button
              Container(
                width: 60.sp,
                height: 60.sp,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isLocked
                      ? LinearGradient(
                          colors: isDark 
                              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                              : [const Color(0xFFFDF7E7), const Color(0xFFF3EAD3)],
                        )
                      : LinearGradient(
                          colors: isDark 
                              ? [startColor, endColor] 
                              : [AppColors.warmTitle, AppColors.warmTitle.withOpacity(0.8)],
                        ),
                  boxShadow: [
                    if (!isLocked)
                      BoxShadow(
                        color: startColor.withOpacity(isDark ? 0.4 : 0.25),
                        blurRadius: isCurrent ? 20 : 12,
                        spreadRadius: isCurrent ? 2 : 0,
                        offset: const Offset(0, 6),
                      ),
                  ],
                ),
                child: Center(
                  child: isLocked
                      ? Icon(Icons.lock_rounded, color: isDark ? Colors.white24 : AppColors.warmTitle.withOpacity(0.25), size: 24.sp)
                      : isCompleted
                          ? Icon(Icons.check_rounded, color: Colors.white, size: 30.sp)
                          : imageUrl != null && imageUrl!.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    imageUrl!,
                                    width: 40.sp,
                                    height: 40.sp,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildDefaultIcon(),
                                  ),
                                )
                              : _buildDefaultIcon(),
                ),
              ),

              // Premium Badge
              if (isPremium && !isCompleted)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4.sp),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.star_rounded, color: Colors.white, size: 12.sp),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: 8.h),
          
          // Title
          SizedBox(
            width: 160.w,
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15.sp,
                height: 1.2,
                letterSpacing: -0.2,
                color: isLocked 
                    ? (isDark ? Colors.white24 : AppColors.warmTitle.withOpacity(0.35))
                    : (isDark ? Colors.white : AppColors.warmTitle),
                fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w800,
                fontFamily: 'SomarSans',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return Icon(Icons.menu_book_rounded, color: Colors.white, size: 24.sp);
  }
}
