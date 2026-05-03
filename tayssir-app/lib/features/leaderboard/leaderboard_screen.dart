import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/features/leaderboard/leaderboard_list_tile.dart';
import 'package:tayssir/features/leaderboard/podium_user_widget.dart';
import 'package:tayssir/features/leaderboard/state/leaderboard_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tayssir/common/core/custom_app_bar.dart';
import 'package:tayssir/providers/user/user_notifier.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/common/bayan_background.dart';

class LeaderboardScreen extends HookConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(leaderboardControllerProvider);
    final leaderboard = controller.leaderboardUsers.asData?.value ?? [];
    final top3 = leaderboard.take(3).toList();
    final others = leaderboard.skip(3).toList();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final scrollController = useScrollController();
    final user = ref.watch(userNotifierProvider).valueOrNull;

    // Mapping state.type to index [0: daily, 1: weekly, 2: global]
    final types = ['daily', 'weekly', 'global'];
    final selectedIdx = types.indexOf(controller.type);
    final selectedTab = selectedIdx != -1 ? selectedIdx : 0; 

    return BayanBackground(
      child: AppScaffold(
        topSafeArea: false,
        paddingX: 0,
        paddingB: 0,
        bodyBackgroundColor: Colors.transparent,
        body: LayoutBuilder(
        builder: (context, constraints) {
          final double availableWidth = constraints.maxWidth;
          final bool isDesktop = availableWidth > 800;
          const double targetContentWidth = 1050;

          final double horizontalPadding = isDesktop 
              ? (availableWidth > targetContentWidth + 160 ? (availableWidth - targetContentWidth) / 2 : 80.0)
              : 20.w;

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async => ref.read(leaderboardControllerProvider.notifier).getLeaderboard(),
                color: AppColors.primaryColor,
                child: CustomScrollView(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    // 1. Standardized Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: horizontalPadding, 
                          right: horizontalPadding, 
                          top: isDesktop ? 30.h : 8.h, 
                          bottom: 16.h
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const CustomAppBar(
                              reverse: true, 
                              showNotifications: false,
                              showThemeToggle: false,
                              showLogo: false,
                            ),
                            Text(
                              "أهل القرآن والسابقون",
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : AppColors.textBlack,
                                fontFamily: 'SomarSans',
                              ),
                            ),
                            SizedBox(width: 44.sp), 
                          ],
                        ),
                      ).animate().fadeIn().slideY(begin: -0.1, end: 0),
                    ),

                    // 2. Tabs
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12.h),
                        padding: EdgeInsets.all(6.sp),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: _buildTab("يومي", selectedTab == 0, () => ref.read(leaderboardControllerProvider.notifier).changeType(0), isDark)),
                            Expanded(child: _buildTab("أسبوعي", selectedTab == 1, () => ref.read(leaderboardControllerProvider.notifier).changeType(1), isDark)),
                            Expanded(child: _buildTab("العالم", selectedTab == 2, () => ref.read(leaderboardControllerProvider.notifier).changeType(2), isDark)),
                          ],
                        ),
                      ),
                    ),

                    // 3. Podium & List
                    if (leaderboard.isEmpty && controller.leaderboardUsers.isLoading)
                      const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
                      )
                    else if (leaderboard.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Text(
                            "لا يوجد متصدرون حالياً",
                            style: TextStyle(color: isDark ? Colors.white38 : Colors.black26, fontSize: 16.sp),
                          ),
                        ),
                      )
                    else ...[
                      // Podium
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 5.h),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkBlue : AppColors.surfaceWhite,
                              borderRadius: BorderRadius.circular(32.r),
                              border: Border.all(
                                color: AppColors.primaryColor.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(0.08),
                                  blurRadius: 40,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (top3.length > 1)
                                  Expanded(
                                    child: PodiumUserWidget(
                                      user: top3[1],
                                      place: 2,
                                      size: isDesktop ? 95.sp : 85.sp,
                                      offsetY: 0,
                                      isDark: isDark,
                                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                                  ),
                                if (top3.isNotEmpty)
                                  Expanded(
                                    child: PodiumUserWidget(
                                      user: top3[0],
                                      place: 1,
                                      size: isDesktop ? 125.sp : 110.sp,
                                      offsetY: 0,
                                      isDark: isDark,
                                    ).animate().fadeIn().scale(duration: 400.ms, curve: Curves.easeOutBack),
                                  ),
                                if (top3.length > 2)
                                  Expanded(
                                    child: PodiumUserWidget(
                                      user: top3[2],
                                      place: 3,
                                      size: isDesktop ? 85.sp : 75.sp,
                                      offsetY: 0,
                                      isDark: isDark,
                                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // List
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 15.h),
                          child: Text(
                            "المرابطون في الحفظ",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppColors.textBlack,
                              fontFamily: 'SomarSans',
                            ),
                          ),
                        ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0),
                      ),

                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index < others.length) {
                                return LeaderboardListTile(
                                  user: others[index],
                                  rank: index + 4,
                                  isDark: isDark,
                                ).animate().fadeIn(delay: (index * 40).clamp(0, 600).ms).slideY(begin: 0.05, end: 0);
                              } else if (controller.canLoadMore) {
                                if (!controller.isFetchingMore) {
                                  Future.microtask(() => ref.read(leaderboardControllerProvider.notifier).fetchMoreLeaderboard());
                                }
                                return const Center(child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(color: AppColors.primaryColor),
                                ));
                              }
                              return null;
                            },
                            childCount: others.length + (controller.canLoadMore ? 1 : 0),
                          ),
                        ),
                      ),
                    ],

                    const SliverToBoxAdapter(child: SizedBox(height: 180)),
                  ],
                ),
              ),

              // 4. Floating My Rank Bar
              if (controller.userRank != null && user != null)
                Positioned(
                  bottom: 30.h,
                  left: horizontalPadding,
                  right: horizontalPadding,
                  child: _MyRankFloatingBar(
                    rank: controller.userRank!,
                    isDark: isDark,
                    userName: user.name,
                  ).animate().fadeIn().slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack),
                ),
            ],
          );
        },
      ),
    ));
  }

  Widget _buildTab(String label, bool isSelected, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 300.ms,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? (isDark ? AppColors.primaryColor : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: isSelected ? [
            BoxShadow(
              color: isDark ? AppColors.primaryColor.withOpacity(0.3) : Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
              color: isSelected ? (isDark ? Colors.white : AppColors.primaryColor) : (isDark ? Colors.white38 : Colors.black26),
              fontFamily: 'SomarSans',
            ),
          ),
        ),
      ),
    );
  }
}

class _MyRankFloatingBar extends StatelessWidget {
  final int rank;
  final bool isDark;
  final String userName;

  const _MyRankFloatingBar({
    required this.rank,
    required this.isDark,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Text(
              '#$rank',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16.sp,
                fontFamily: 'SomarSans',
              ),
            ),
          ),
          20.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'رتبة ولايتك',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SomarSans',
                  ),
                ),
                Text(
                  userName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'SomarSans',
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.stars_rounded, color: Colors.white, size: 30),
        ],
      ),
    );
  }
}
