import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/common/core/shield_badge.dart';
import 'package:tayssir/features/streaks/presentation/streak_notifier.dart';
import 'package:tayssir/common/app_buttons/big_button.dart';
import 'package:tayssir/features/profile/utils/achievement_share_utils.dart';
import 'package:tayssir/providers/data/data_provider.dart';
import 'package:tayssir/providers/user/user_notifier.dart';
import 'package:tayssir/resources/resources.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AchievementLogScreen extends ConsumerStatefulWidget {
  const AchievementLogScreen({super.key});

  @override
  ConsumerState<AchievementLogScreen> createState() =>
      _AchievementLogScreenState();
}

class _AchievementLogScreenState extends ConsumerState<AchievementLogScreen> {
  final screenshotController = ScreenshotController();

  Future<void> _shareScreen() async {
    final user = ref.read(userNotifierProvider).valueOrNull;
    if (user == null) return;
    
    final streak = ref.read(streakNotifierProvider).asData?.value;
    final dataState = ref.read(dataProvider);

    final completedLessons =
        dataState.contentData.chapters.where((e) => e.progress >= 50).length;
    final perfectResults =
        dataState.contentData.chapters.where((e) => e.progress == 100).length;

    await AchievementShareUtils.shareAchievementLog(
      context,
      user: user,
      streak: streak,
      completedLessons: completedLessons,
      perfectResults: perfectResults,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userNotifierProvider).valueOrNull;
    if (user == null) {
      return const AppScaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final streak = ref.watch(streakNotifierProvider).asData?.value;
    final dataState = ref.watch(dataProvider);

    final completedLessons =
        dataState.contentData.chapters.where((e) => e.progress >= 50).length;
    final perfectResults =
        dataState.contentData.chapters.where((e) => e.progress == 100).length;

    String rank = "مبتدئ";
    if (user.points >= 10000) {
      rank = "أسطورة";
    } else if (user.points >= 6000) {
      rank = "متميز";
    } else if (user.points >= 3000) {
      rank = "مثابر";
    } else if (user.points >= 1500) {
      rank = "مستكشف";
    } else if (user.points >= 500) {
      rank = "ناشئ";
    }
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 900;

    return AppScaffold(
      topSafeArea: true,
      paddingX: 0,
      bodyBackgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isDesktop ? 600.w : double.infinity),
          child: Column(
            children: [
              // ── Header ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp, color: isDark ? Colors.white : AppColors.textBlack),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "سجل الإنجازات",
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'SomarSans',
                        color: isDark ? Colors.white : AppColors.textBlack,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 44), 
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      20.verticalSpace,
                      
                      // ── Shield/Level Section ──
                      _ShieldWidget(
                        userAvatarUrl: user.completeProfilePic,
                        level: user.points,
                        rank: rank,
                        badgeIconUrl: user.badge?.completeIconUrl,
                        badgeColor: user.badge?.color,
                      ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),

                      30.verticalSpace,

                      // ── Stats Section Title ──
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: [
                            Text(
                              "إحصائيات الحفظ",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white60 : Colors.black45,
                                fontFamily: 'SomarSans',
                              ),
                            ),
                            12.horizontalSpace,
                            Expanded(child: Divider(color: isDark ? Colors.white10 : Colors.black12)),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      20.verticalSpace,

                      // ── Achievement Grid/List ──
                      _AchievementCard(
                        icon: SVGs.icStreakAchievement,
                        title: "أيام الحفظ المتواصلة",
                        value: "${streak?.currentStreak ?? 0} يوم",
                        valueColor: const Color(0xFFF97316),
                        isDark: isDark,
                      ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),
                      
                      16.verticalSpace,
                      
                      _AchievementCard(
                        icon: SVGs.icPointsAchievement,
                        title: "إجمالي النقاط المجمعة",
                        value: "${user.points} نقطة",
                        valueColor: const Color(0xFF00C4F6),
                        isDark: isDark,
                      ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),
                      
                      16.verticalSpace,
                      
                      _AchievementCard(
                        icon: SVGs.icLessonsAchievement,
                        title: "الدروس التي أتممتها",
                        value: "$completedLessons درس",
                        valueColor: const Color(0xFF22C55E),
                        isDark: isDark,
                      ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0),
                      
                      16.verticalSpace,
                      
                      _AchievementCard(
                        icon: SVGs.icPerfectAchievement,
                        title: "العلامات الكاملة (100%)",
                        value: "$perfectResults درس",
                        valueColor: const Color(0xFFD946EF),
                        isDark: isDark,
                      ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1, end: 0),

                      40.verticalSpace,
                    ],
                  ),
                ),
              ),

              // ── Bottom Share Action ──
              Container(
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 24.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: BigButton(
                  text: "مشاركة الإنجاز",
                  onPressed: _shareScreen,
                  buttonType: ButtonType.primary,
                ),
              ).animate().slideY(begin: 1, end: 0, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShieldWidget extends StatelessWidget {
  final String userAvatarUrl;
  final int level;
  final String rank;
  final String? badgeIconUrl;
  final String? badgeColor;

  const _ShieldWidget({
    required this.userAvatarUrl,
    required this.level,
    required this.rank,
    this.badgeIconUrl,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = badgeColor != null
        ? Color(int.parse(badgeColor!.replaceAll('#', '0xFF')))
        : AppColors.primaryColor;

    return SizedBox(
      height: 250.h,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Background Glow
          Container(
            width: 180.w,
            height: 180.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: themeColor.withOpacity(0.1),
                  blurRadius: 60,
                  spreadRadius: 10,
                ),
              ],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 2.seconds),

          ShieldBadge(
            userAvatarUrl: userAvatarUrl,
            badgeIconUrl: badgeIconUrl,
            themeColor: themeColor,
            width: 180.w,
            height: 210.h,
            avatarPaddingTop: 48.h,
            avatarSize: 150.w,
            avatarOffsetX: -2.w,
          ),

          // Level Badge (Floating at bottom of shield)
          Positioned(
            bottom: 10.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _LevelNumber(
                number: "$level",
                themeColor: themeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelNumber extends StatelessWidget {
  final String number;
  final Color themeColor;

  const _LevelNumber({required this.number, required this.themeColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      number,
      style: TextStyle(
        fontFamily: 'SomarSans',
        fontSize: 28.sp,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        height: 1,
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String icon;
  final String title;
  final String value;
  final Color valueColor;
  final bool isDark;

  const _AchievementCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.valueColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            // Icon Container
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: valueColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: SvgPicture.asset(icon, width: 28.w, height: 28.h),
            ),
            20.horizontalSpace,
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontFamily: 'SomarSans',
                    ),
                  ),
                  4.verticalSpace,
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: valueColor,
                      fontFamily: 'SomarSans',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
