import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tayssir/router/app_router.dart';
import 'package:tayssir/providers/data/data_provider.dart';
import 'package:tayssir/providers/data/models/material_model.dart';
import 'package:tayssir/providers/user/user_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tayssir/common/custom_cached_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/features/home/presentation/widgets/course_widget.dart';
import 'package:tayssir/features/home/presentation/view_style.dart';
import 'package:tayssir/features/home/presentation/subscribe_section.dart';
import 'package:tayssir/features/challanges/data/social_repository.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/common/core/profile_button.dart';
import 'package:tayssir/services/actions/dialog_service.dart';
import 'package:tayssir/features/challanges/data/challenge_limits_manager.dart';

final friendsProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(socialRepositoryProvider).getFriends();
});

class ChallengeDashboardScreen extends ConsumerStatefulWidget {
  const ChallengeDashboardScreen({super.key});

  @override
  ConsumerState<ChallengeDashboardScreen> createState() => _ChallengeDashboardScreenState();
}

class _ChallengeDashboardScreenState extends ConsumerState<ChallengeDashboardScreen> {
  ViewStyle _viewStyle = ViewStyle.grid;

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(dataProvider).contentData.modules;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      paddingB: 0,
      paddingX: 0,
      paddingY: 0,
      includeBackButton: false,
      topSafeArea: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double availableWidth = constraints.maxWidth;
          final bool isDesktop = availableWidth > 800;
          const double targetContentWidth = 1050;

          // Standardized centering and alignment logic
          final double horizontalPadding = isDesktop 
              ? (availableWidth > targetContentWidth + 160 ? (availableWidth - targetContentWidth) / 2 : 80.0)
              : 20.w;

          return CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              // 1. Integrated Header (Profile Button Right | Title Center | Back Button Left)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(horizontalPadding, 4.h, horizontalPadding, 10.h),
                  child: Row(
                    children: [
                      const ProfileButton(),
                      const Spacer(),
                      Text(
                        'لوحة التحديات',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.textBlack,
                          fontFamily: 'SomarSans',
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Container(
                          width: 44.sp,
                          height: 44.sp,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                            ),
                          ),
                          child: Icon(
                            isDesktop ? Icons.arrow_back_ios_rounded : Icons.arrow_back_ios_rounded,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Subscribe Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: const SubscribeSection(showProgress: false),
                )
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 400.ms)
                    .slideX(begin: 0.1, end: 0),
              ),

              // 3. Friends Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20.h),
                  child: _buildFriendsSection(context),
                ).animate().fadeIn(delay: 300.ms, duration: 450.ms).slideY(begin: 0.1, end: 0),
              ),

              // 4. Section Title with Toggle
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10.h),
                  child: _buildSectionTitle(context),
                ).animate().fadeIn(delay: 450.ms, duration: 400.ms),
              ),

              // 5. Materials Grid/List
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 0),
                sliver: _viewStyle == ViewStyle.grid
                    ? SliverGrid(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: isDesktop ? 550 : 204,
                          mainAxisSpacing: 16.h,
                          crossAxisSpacing: 16.w,
                          mainAxisExtent: isDesktop ? 135.h : 170.h,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return CardWidget(
                              title: courses[index].title,
                              subTitle: courses[index].description ?? 'أزيد من 300 سؤال\nو 150 تمرين',
                              onPressed: () => _showUnitPicker(context, courses[index], _hexToColor(courses[index].gradiantColorStart)),
                              startColor: _hexToColor(courses[index].gradiantColorStart),
                              endColor: _hexToColor(courses[index].gradiantColorEnd),
                              imageList: courses[index].imageList,
                              imageGrid: courses[index].imageGrid,
                              isGrid: true,
                            ).animate().fadeIn(delay: (index * 50).ms).scale(curve: Curves.easeOutCubic);
                          },
                          childCount: courses.length,
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: CardWidget(
                                title: courses[index].title,
                                subTitle: courses[index].description ?? 'أزيد من 300 سؤال و 150 تمرين',
                                onPressed: () => _showUnitPicker(context, courses[index], _hexToColor(courses[index].gradiantColorStart)),
                                startColor: _hexToColor(courses[index].gradiantColorStart),
                                endColor: _hexToColor(courses[index].gradiantColorEnd),
                                imageList: courses[index].imageList,
                                imageGrid: courses[index].imageGrid,
                                isGrid: false,
                              ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0),
                            );
                          },
                          childCount: courses.length,
                        ),
                      ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFriendsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final friendsAsync = ref.watch(friendsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'أصدقاؤك المتصلون',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.textBlack,
                fontFamily: 'SomarSans',
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.pushNamed(AppRoutes.social.name),
              child: Text(
                'البحث عن صديق',
                style: TextStyle(color: const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13.sp),
              ),
            ),
          ],
        ),
        8.verticalSpace,
        SizedBox(
          height: 100.h,
          child: friendsAsync.when(
            data: (friends) => friends.isEmpty
                ? Center(
                    child: Text(
                      'لا يوجد أصدقاء متصلون حالياً',
                      style: TextStyle(color: isDark ? Colors.white38 : Colors.black26, fontSize: 12.sp),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      return Container(
                        width: 70.w,
                        margin: EdgeInsets.only(right: 12.w),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 60.r,
                                  height: 60.r,
                                  decoration: const BoxDecoration(shape: BoxShape.circle),
                                  clipBehavior: Clip.antiAlias,
                                  child: CustomCachedImage(
                                    imageUrl: friend['image']?.toString() ?? '',
                                    errorWidget: const Icon(Icons.person),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 15.r,
                                    height: 15.r,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            4.verticalSpace,
                            Text(
                              friend['name'],
                              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => const SizedBox(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text(
          'اختر مادة للتحدي',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.textBlack,
            fontFamily: 'SomarSans',
          ),
        ),
        const Spacer(),
        _buildViewToggle(),
      ],
    );
  }

  Widget _buildViewToggle() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          _ToggleIcon(
            icon: Icons.grid_view_rounded,
            isSelected: _viewStyle == ViewStyle.grid,
            onTap: () => setState(() => _viewStyle = ViewStyle.grid),
          ),
          _ToggleIcon(
            icon: Icons.view_headline_rounded,
            isSelected: _viewStyle == ViewStyle.list,
            onTap: () => setState(() => _viewStyle = ViewStyle.list),
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String colorStr) {
    String s = colorStr.replaceAll('#', '');
    if (s.length == 6) s = 'FF$s';
    return Color(int.parse(s, radix: 16));
  }

  void _showUnitPicker(BuildContext context, MaterialModel course, Color themeColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dataState = ref.read(dataProvider);
    final units = dataState.getUnitsByCourseId(course.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Column(
          children: [
            12.verticalSpace,
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
            20.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(color: themeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
                    child: Icon(Icons.explore_rounded, color: themeColor),
                  ),
                  12.horizontalSpace,
                  Text(
                    'اختر وحدة من ${course.title}',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, fontFamily: 'SomarSans'),
                  ),
                ],
              ),
            ),
            20.verticalSpace,
            Expanded(
              child: units.isEmpty
                  ? Center(child: Text('لا توجد وحدات متوفرة حالياً'))
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      itemCount: units.length,
                      itemBuilder: (context, i) => InkWell(
                        onTap: () async {
                          final isPremium = ref.read(userNotifierProvider).valueOrNull?.isSub ?? false;
                          final canPlay = await ChallengeLimitsManager.canPlayArena(isPremium);
                          if (!canPlay) {
                            if (context.mounted) {
                              Navigator.pop(ctx);
                              DialogService.showNeedSubscriptionDialog(context);
                            }
                            return;
                          }
                          await ChallengeLimitsManager.incrementArenaCount();
                          
                          if (context.mounted) {
                            Navigator.pop(ctx);
                            context.pushNamed(AppRoutes.challengeMatchmaking.name, extra: {'unitId': units[i].id, 'courseTitle': course.title});
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                units[i].title,
                                style: TextStyle(
                                  color: isDark ? Colors.white : AppColors.textBlack,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp,
                                  fontFamily: 'SomarSans',
                                ),
                              ),
                              const Icon(Icons.play_circle_fill, color: Colors.amber, size: 30),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleIcon({required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: isSelected ? (isDark ? const Color(0xFF10B981) : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: isSelected && !isDark ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
        ),
        child: Icon(icon, size: 20.sp, color: isSelected ? (isDark ? Colors.white : const Color(0xFF10B981)) : (isDark ? Colors.white38 : Colors.black26)),
      ),
    );
  }
}
