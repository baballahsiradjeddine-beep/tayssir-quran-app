import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayssir/features/units/widgets/animated_circular_progress_widget.dart';
import 'package:tayssir/providers/special_effect/special_effect_provider.dart';
import 'package:tayssir/providers/user/user_notifier.dart';
import 'package:tayssir/services/actions/dialog_service.dart';
import 'package:tayssir/resources/colors/app_colors.dart';

class CustomLessonWidget extends ConsumerWidget {
  const CustomLessonWidget({
    super.key,
    required this.isCurrent,
    this.onPressed,
    required this.title,
    required this.progress,
    this.imageUrl,
    this.isPremium = false,
    this.forceListLayout = false,
  });

  final String title;
  final bool isCurrent;
  final VoidCallback? onPressed;
  final double progress;
  final String? imageUrl;
  final bool isPremium;
  final bool forceListLayout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userNotifierProvider).valueOrNull;
    final isSub = user?.isSub ?? false;
    final bool isLocked = onPressed == null;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isComplete = progress >= 100;

    IconData getLessonIcon() {
      if (isLocked) return Icons.lock_rounded;
      if (isComplete) return Icons.check_circle_rounded;
      if (progress > 0) return Icons.timelapse_rounded;
      return Icons.play_arrow_rounded;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 500;

        if (isDesktop && !forceListLayout) {
          return _DesktopCard(
            title: title,
            progress: progress,
            imageUrl: imageUrl,
            isLocked: isLocked,
            isCurrent: isCurrent,
            isComplete: isComplete,
            isPremium: isPremium,
            isDark: isDark,
            isSub: isSub,
            lessonIcon: getLessonIcon(),
            onTap: () {
              if (isPremium && !isSub) {
                DialogService.showNeedSubscriptionDialog(context);
                return;
              }
              if (onPressed != null) {
                ref.read(specialEffectServiceProvider).playEffects();
                onPressed!();
              } else {
                DialogService.showChapterLockedDialog(context);
              }
            },
          );
        }

        return _MobileCard(
          title: title,
          progress: progress,
          imageUrl: imageUrl,
          isLocked: isLocked,
          isCurrent: isCurrent,
          isComplete: isComplete,
          isPremium: isPremium,
          isDark: isDark,
          isSub: isSub,
          lessonIcon: getLessonIcon(),
          onTap: () {
            if (isPremium && !isSub) {
              DialogService.showNeedSubscriptionDialog(context);
              return;
            }
            if (onPressed != null) {
              ref.read(specialEffectServiceProvider).playEffects();
              onPressed!();
            } else {
              DialogService.showChapterLockedDialog(context);
            }
          },
        );
      },
    );
  }
}

class _DesktopCard extends StatefulWidget {
  final String title;
  final double progress;
  final String? imageUrl;
  final bool isLocked;
  final bool isCurrent;
  final bool isComplete;
  final bool isPremium;
  final bool isDark;
  final bool isSub;
  final IconData lessonIcon;
  final VoidCallback onTap;

  const _DesktopCard({
    required this.title,
    required this.progress,
    required this.imageUrl,
    required this.isLocked,
    required this.isCurrent,
    required this.isComplete,
    required this.isPremium,
    required this.isDark,
    required this.isSub,
    required this.lessonIcon,
    required this.onTap,
  });

  @override
  State<_DesktopCard> createState() => _DesktopCardState();
}

class _DesktopCardState extends State<_DesktopCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = widget.isLocked
        ? (widget.isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))
        : const Color(0xFF10B981); // Emerald

    final Color textColor = widget.isLocked
        ? (widget.isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))
        : (widget.isDark ? Colors.white : const Color(0xFF1E293B));

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered && !widget.isLocked ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
              border: Border.all(
                color: widget.isCurrent 
                  ? const Color(0xFF10B981) 
                  : (widget.isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9)),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(widget.isDark ? 0.3 : 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
                if (widget.isCurrent)
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
                child: Row(
                  children: [
                    AnimatedCircularProgressWidget(
                      percentage: widget.progress,
                      color: widget.isLocked ? Colors.grey : const Color(0xFF10B981),
                      imageUrl: widget.imageUrl,
                      size: 54,
                      borderWidth: 3.5,
                      isLocked: widget.isLocked,
                      backgroundColor: Colors.transparent,
                    ),
                    20.horizontalSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'SomarSans',
                              height: 1.2,
                            ),
                          ),
                          4.verticalSpace,
                          Row(
                            children: [
                              Icon(widget.lessonIcon, size: 14.sp, color: const Color(0xFF10B981)),
                              8.horizontalSpace,
                              Text(
                                widget.isLocked ? 'مغلق' : (widget.isComplete ? 'مكتمل ✅' : 'ابدأ الآن ✨'),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SomarSans',
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileCard extends StatelessWidget {
  final String title;
  final double progress;
  final String? imageUrl;
  final bool isLocked;
  final bool isCurrent;
  final bool isComplete;
  final bool isPremium;
  final bool isDark;
  final bool isSub;
  final IconData lessonIcon;
  final VoidCallback onTap;

  const _MobileCard({
    required this.title,
    required this.progress,
    required this.imageUrl,
    required this.isLocked,
    required this.isCurrent,
    required this.isComplete,
    required this.isPremium,
    required this.isDark,
    required this.isSub,
    required this.lessonIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          border: Border.all(
            color: isCurrent 
                ? const Color(0xFF10B981) 
                : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9)),
            width: isCurrent ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
            if (isCurrent)
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 1,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Stack(
            children: [
              // Subtle background gradient for current lesson
              if (isCurrent)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 100.w,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF10B981).withOpacity(0.1),
                          const Color(0xFF10B981).withOpacity(0.0),
                        ],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                    ),
                  ),
                ),
              
              Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      // Progress Image
                      AnimatedCircularProgressWidget(
                        percentage: progress,
                        color: isLocked ? Colors.grey : const Color(0xFF10B981),
                        imageUrl: imageUrl,
                        size: 54,
                        borderWidth: 3.5,
                        isLocked: isLocked,
                        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      ),
                      
                      20.horizontalSpace,
                      
                      // Text info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isLocked 
                                  ? (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))
                                  : (isDark ? Colors.white : const Color(0xFF1E293B)),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'SomarSans',
                                height: 1.2,
                              ),
                            ),
                            4.verticalSpace,
                            Row(
                              children: [
                                if (isPremium && !isSub)
                                  Padding(
                                    padding: EdgeInsets.only(left: 8.w),
                                    child: Icon(Icons.stars_rounded, size: 16.sp, color: const Color(0xFFF59E0B)),
                                  ),
                                Text(
                                  isLocked 
                                    ? 'الفصل التالي' 
                                    : (isComplete ? 'مكتمل ✅' : (progress > 0 ? 'تابع التعلم ✨' : 'ابدأ الآن 🚀')),
                                  style: TextStyle(
                                    color: isLocked ? Colors.grey : const Color(0xFF10B981),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'SomarSans',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Action Icon
                      Container(
                        width: 40.sp,
                        height: 40.sp,
                        decoration: BoxDecoration(
                          color: isLocked 
                              ? Colors.transparent 
                              : const Color(0xFF10B981).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          lessonIcon,
                          color: isLocked 
                              ? (isDark ? Colors.white12 : Colors.grey.shade300) 
                              : const Color(0xFF10B981),
                          size: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
