import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayssir/resources/colors/app_colors.dart';

class ExerciseHeader extends StatelessWidget {
  final double progress;

  const ExerciseHeader({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          return Stack(
            alignment: Alignment.centerRight,
            children: [
              // Glassy Background Bar
              Container(
                height: 10.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              
              // Elegant Progress Bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                width: availableWidth * progress.clamp(0.01, 1.0),
                height: 10.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                        ? [
                            AppColors.goldColorLight,
                            AppColors.goldColor,
                          ]
                        : [
                            const Color(0xFF7C4A27), // warmTitle (Darker)
                            const Color(0xFFB45309), // warmAccent (Primary)
                          ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppColors.goldColor : AppColors.warmAccent).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Stack(
                    children: [
                      // Inner Shine
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 4.h,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
