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
        : (widget.isDark ? const Color(0xFF10B981) : AppColors.warmTitle); // Emerald or Bronze

    final Color textColor = widget.isLocked
        ? (widget.isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))
        : (widget.isDark ? Colors.white : AppColors.warmTitle);

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
                  ? (widget.isDark ? const Color(0xFF10B981) : AppColors.warmTitle) 
                  : (widget.isDark ? Colors.white.withOpacity(0.05) : AppColors.warmBorder),
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
                    color: (widget.isDark ? const Color(0xFF10B981) : AppColors.warmAccent).withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Directionality(
              textDirection: Directionality.of(context),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
                child: Row(
                  children: [
                    AnimatedCircularProgressWidget(
                      percentage: widget.progress,
                      color: widget.isLocked ? Colors.grey : (widget.isDark ? const Color(0xFF10B981) : AppColors.warmTitle),
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
                          if (widget.isLocked || widget.isComplete)
                            Column(
                              children: [
                                4.verticalSpace,
                                Row(
                                  children: [
                                    Icon(widget.lessonIcon, size: 14.sp, color: widget.isDark ? const Color(0xFF10B981) : AppColors.warmTitle),
                                    8.horizontalSpace,
                                    Text(
                                      widget.isLocked ? 'مغلق' : 'مكتمل ✅',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'SomarSans',
                                        color: widget.isDark ? const Color(0xFF10B981) : AppColors.warmTitle,
                                      ),
                                    ),
                                  ],
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
    final Color activeColor = isDark ? const Color(0xFF10B981) : AppColors.emerald700;
    final Color goldAccent = const Color(0xFFD97706);
    final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: isCurrent 
            ? LinearGradient(
                colors: isDark 
                    ? [const Color(0xFF0F172A), const Color(0xFF1E293B)] 
                    : [const Color(0xFFFFFBEB), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
          color: isCurrent ? null : cardBg,
          border: Border.all(
            color: isCurrent 
                ? goldAccent.withOpacity(0.3) 
                : (isDark ? Colors.white.withOpacity(0.04) : AppColors.emerald600.withOpacity(0.06)),
            width: isCurrent ? 2.0 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            if (isCurrent)
              BoxShadow(
                color: goldAccent.withOpacity(isDark ? 0.12 : 0.06),
                blurRadius: 20,
                spreadRadius: 2,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Stack(
            children: [
              // Bottom Progress Bar (Subtle)
              Positioned(
                bottom: 0, left: 0, right: 0,
                height: 4.h,
                child: Container(
                  color: (isDark ? Colors.white : AppColors.emerald600).withOpacity(0.05),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerRight,
                    widthFactor: progress / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            isCurrent ? goldAccent : activeColor,
                            (isCurrent ? goldAccent : activeColor).withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
                child: Directionality(
                  textDirection: Directionality.of(context),
                  child: Row(
                    children: [
                      // Folder/Unit Image with Progress Ring
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedCircularProgressWidget(
                            percentage: progress,
                            color: isLocked ? Colors.grey : (isCurrent ? goldAccent : activeColor),
                            imageUrl: imageUrl,
                            size: 56.sp,
                            borderWidth: 3.0,
                            isLocked: isLocked,
                            backgroundColor: isDark ? Colors.black26 : Colors.grey.shade50,
                          ),
                          if (isComplete)
                            Positioned(
                              bottom: 0, right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: Icon(Icons.check_circle, size: 16.sp, color: activeColor),
                              ),
                            ),
                        ],
                      ),
                      
                      16.horizontalSpace,
                      
                      // Info
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
                                  : (isDark ? Colors.white : AppColors.emerald900),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'SomarSans',
                                height: 1.2,
                              ),
                            ),
                            6.verticalSpace,
                            Row(
                              children: [
                                if (isPremium && !isSub)
                                  Padding(
                                    padding: EdgeInsets.only(left: 6.w),
                                    child: Icon(Icons.stars_rounded, size: 14.sp, color: goldAccent),
                                  ),
                                Text(
                                  isLocked 
                                    ? 'الفصل التالي' 
                                    : (isComplete ? 'تم الإنجاز بنجاح ✓' : (isCurrent ? 'تابع تعلمك الآن ✨' : 'ابدأ الدرس')),
                                  style: TextStyle(
                                    color: isLocked 
                                        ? (isDark ? Colors.white12 : Colors.grey.shade400)
                                        : (isCurrent ? goldAccent : activeColor).withOpacity(0.9),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'SomarSans',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      10.horizontalSpace,

                      // Play Button
                      Container(
                        width: 42.sp, height: 42.sp,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isLocked 
                            ? null 
                            : LinearGradient(
                                colors: isCurrent 
                                  ? [goldAccent, const Color(0xFFB45309)] 
                                  : [activeColor, activeColor.withOpacity(0.8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                          color: isLocked ? (isDark ? Colors.white10 : Colors.grey.shade100) : null,
                          boxShadow: isLocked ? null : [
                            BoxShadow(
                              color: (isCurrent ? goldAccent : activeColor).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Icon(
                          isLocked ? Icons.lock_rounded : (isComplete ? Icons.replay_rounded : Icons.play_arrow_rounded),
                          color: isLocked ? (isDark ? Colors.white24 : Colors.grey.shade400) : Colors.white,
                          size: 22.sp,
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
