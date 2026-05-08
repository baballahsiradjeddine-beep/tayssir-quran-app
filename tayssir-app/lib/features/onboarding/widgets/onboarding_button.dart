import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayssir/resources/colors/app_colors.dart';

class OnboardingButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onPressed;
  final Color? color;

  const OnboardingButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = color ?? (isDark ? const Color(0xFF10B981) : AppColors.warmAccent);

    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 58.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: enabled ? buttonColor : (isDark ? const Color(0xFF1E293B) : AppColors.warmBorder.withOpacity(0.3)),
          border: Border.all(
            color: enabled ? buttonColor : (isDark ? const Color(0xFF334155) : AppColors.warmBorder),
            width: 2,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: buttonColor.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: enabled ? Colors.white : (isDark ? const Color(0xFF475569) : AppColors.warmSubtitle),
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'SomarSans',
            ),
          ),
        ),
      ),
    )
        .animate(target: enabled ? 1 : 0)
        .scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1));
  }
}
