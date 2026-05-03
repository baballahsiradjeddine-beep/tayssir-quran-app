import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../environment_config.dart';

class OptionSelection extends StatelessWidget {
  final String? iconPath;
  final IconData? iconData;
  final String text;
  final String? subText;
  final VoidCallback onPressed;
  final bool isSelected;
  final Color? activeColor;
  final Color? accentColor;

  const OptionSelection({
    super.key,
    this.iconPath,
    this.iconData,
    required this.text,
    this.subText,
    required this.onPressed,
    required this.isSelected,
    this.activeColor,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color effectiveActiveColor = activeColor ?? const Color(0xFF10B981);
    final Color effectiveAccentColor = accentColor ?? const Color(0xFFF59E0B);

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isDark ? (isSelected ? effectiveActiveColor.withOpacity(0.08) : const Color(0xFF1E293B)) : (isSelected ? effectiveActiveColor.withOpacity(0.08) : Colors.white),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? effectiveActiveColor : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: effectiveActiveColor.withOpacity(0.12),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ] : [
            BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4)
            )
          ],
        ),
        child: Stack(
          children: [
            // Accent Line for specific methods (e.g., Payment categories)
            if (accentColor != null)
              Positioned(
                top: -16.r, // Bleed through padding to the top edge
                bottom: -16.r, // Bleed through padding to the bottom edge
                right: -16.r, // Align with the absolute right edge of the container
                child: Container(
                  width: 8.r,
                  decoration: BoxDecoration(
                    color: effectiveAccentColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20.r), 
                      bottomRight: Radius.circular(20.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: effectiveAccentColor.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(-2, 0),
                      )
                    ],
                  ),
                ),
              ),
              
            Row(
              children: [
                // Icon/Graphics
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: isSelected ? effectiveActiveColor.withOpacity(0.1) : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: iconData != null
                        ? Icon(iconData, color: isSelected ? effectiveActiveColor : Colors.grey.shade500, size: 24.sp)
                        : (iconPath != null && iconPath!.isNotEmpty
                            ? (iconPath!.startsWith('assets/') 
                                ? (iconPath!.endsWith('.svg')
                                    ? SvgPicture.asset(iconPath!, width: 24.w, height: 24.h, colorFilter: ColorFilter.mode(isSelected ? effectiveActiveColor : Colors.grey.shade500, BlendMode.srcIn))
                                    : Image.asset(iconPath!, width: 24.w, height: 24.h))
                                : (iconPath!.endsWith('.svg') || iconPath!.contains('.svg?')
                                    ? SvgPicture.network(
                                        EnvironmentConfig.resolveImageUrl(iconPath!),
                                        width: 24.w,
                                        height: 24.h,
                                        placeholderBuilder: (context) => SizedBox(width: 24.w, height: 24.h, child: const CircularProgressIndicator(strokeWidth: 2)),
                                      )
                                    : Image.network(
                                        EnvironmentConfig.resolveImageUrl(iconPath!), 
                                        width: 24.w, 
                                        height: 24.h, 
                                        errorBuilder: (context, error, stackTrace) => Icon(Icons.public, color: isSelected ? effectiveActiveColor : Colors.grey.shade500, size: 22.sp),
                                      )))
                            : Icon(Icons.help_outline, color: isSelected ? effectiveActiveColor : Colors.grey.shade500, size: 24.sp)),
                  ),
                ),
                
                16.horizontalSpace,
                
                // Text content properly expanded to avoid clipping
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'SomarSans',
                        ),
                      ),
                      if (subText != null) ...[
                        2.verticalSpace,
                        Text(
                          subText!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.grey.shade500,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SomarSans',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Radio Indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 22.r,
                  height: 22.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? effectiveActiveColor : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                      width: 2,
                    ),
                    color: isSelected ? effectiveActiveColor : Colors.transparent,
                    boxShadow: isSelected ? [BoxShadow(color: effectiveActiveColor.withOpacity(0.35), blurRadius: 10)] : [],
                  ),
                  child: isSelected 
                    ? const Center(child: Icon(Icons.check, color: Colors.white, size: 12)) 
                    : null,
                ),
              ],
            ),
          ],
        ),
      ).animate(target: isSelected ? 1 : 0)
        .scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02), duration: 200.ms),
    );
  }
}
