import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tayssir/router/app_router.dart';
import 'package:tayssir/providers/data/data_provider.dart';
import 'package:tayssir/providers/data/models/material_model.dart';
import 'package:tayssir/providers/user/user_notifier.dart';
import 'package:tayssir/common/custom_cached_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/common/core/profile_button.dart';
import 'package:tayssir/services/actions/dialog_service.dart';
import 'package:tayssir/features/challanges/data/challenge_limits_manager.dart';
import 'package:tayssir/features/challanges/presentation/widgets/streak_widget.dart';
import 'package:tayssir/features/challanges/presentation/widgets/flash_challenge_widget.dart';

import 'package:tayssir/features/challanges/data/social_repository.dart';

final friendsProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(socialRepositoryProvider).getFriends();
});

class ChallengeDashboardScreen extends ConsumerStatefulWidget {
  const ChallengeDashboardScreen({super.key});

  @override
  ConsumerState<ChallengeDashboardScreen> createState() => _ChallengeDashboardScreenState();
}

class _ChallengeDashboardScreenState extends ConsumerState<ChallengeDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final modules = ref.watch(dataProvider).contentData.modules;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final quranMaterials = modules.where((m) => m.type == 'quran').toList();
    final ahkamMaterials = modules.where((m) => m.type == 'ahkam').toList();
    final storiesMaterials = modules.where((m) => m.type == 'stories').toList();

    return AppScaffold(
      bodyBackgroundColor: isDark ? null : AppColors.warmBackground,
      paddingB: 0,
      paddingX: 0,
      paddingY: 0,
      includeBackButton: false,
      topSafeArea: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double availableWidth = constraints.maxWidth;
          final bool isDesktop = availableWidth > 800;
          final double horizontalPadding = isDesktop ? (availableWidth - 700) / 2 : 20.w;

          return CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              // 1. Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(horizontalPadding, 4.h, horizontalPadding, 10.h),
                  child: Row(
                    children: [
                      const ProfileButton(),
                      const Spacer(),
                      Text(
                        'مجالس المنافسة',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.warmTitle,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
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
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.05) : AppColors.warmBorder,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Streak Widget
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10.h),
                  child: const StreakWidget(),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
              ),

              // 3. Flash Challenge
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10.h),
                  child: const FlashChallengeWidget(),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
              ),

              // 4. Pavilions Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(horizontalPadding, 30.h, horizontalPadding, 15.h),
                  child: Text(
                    "اختر جناح المنافسة",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.warmTitle,
                      fontFamily: 'SomarSans',
                    ),
                  ),
                ),
              ),

              // 5. Pavilions Content
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildPavilionCard(
                      title: "جناح القراء",
                      subtitle: "تحديات الحفظ، إكمال الآيات، ومخارج الحروف",
                      icon: "📖",
                      materials: quranMaterials,
                      startColor: const Color(0xFF059669),
                      endColor: const Color(0xFF10B981),
                      isDark: isDark,
                    ),
                    16.verticalSpace,
                    _buildPavilionCard(
                      title: "مجلس التجويد",
                      subtitle: "تحديات الأحكام، النون الساكنة، والمدود",
                      icon: "📜",
                      materials: ahkamMaterials,
                      startColor: const Color(0xFFD97706),
                      endColor: const Color(0xFFF59E0B),
                      isDark: isDark,
                    ),
                    16.verticalSpace,
                    _buildPavilionCard(
                      title: "روضة القصص",
                      subtitle: "تحديات السيرة النبوية، قصص الأنبياء والعبر",
                      icon: "🌙",
                      materials: storiesMaterials,
                      startColor: const Color(0xFF7C3AED),
                      endColor: const Color(0xFF8B5CF6),
                      isDark: isDark,
                    ),
                  ]),
                ),
              ),

              // 6. Friends Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 30.h),
                  child: _buildFriendsSection(context),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 50)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPavilionCard({
    required String title,
    required String subtitle,
    required String icon,
    required List<MaterialModel> materials,
    required Color startColor,
    required Color endColor,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showMaterialPicker(title, materials, startColor),
          borderRadius: BorderRadius.circular(30.r),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            icon,
                            style: TextStyle(fontSize: 24.sp),
                          ),
                          12.horizontalSpace,
                          Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'SomarSans',
                            ),
                          ),
                        ],
                      ),
                      8.verticalSpace,
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14.sp,
                          fontFamily: 'SomarSans',
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  void _showMaterialPicker(String title, List<MaterialModel> materials, Color themeColor) {
    if (materials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("هذا الجناح سيفتح قريباً بإذن الله")),
      );
      return;
    }
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
        ),
        child: Column(
          children: [
            12.verticalSpace,
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
            30.verticalSpace,
            Text(
              "اختر موضوعاً في $title",
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, fontFamily: 'SomarSans'),
            ),
            20.verticalSpace,
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                itemCount: materials.length,
                itemBuilder: (context, index) {
                  final mat = materials[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: themeColor.withOpacity(0.1)),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16.r),
                      leading: Container(
                        width: 50.r,
                        height: 50.r,
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CustomCachedImage(
                            imageUrl: mat.imageGrid,
                            width: 30.r,
                            height: 30.r,
                            errorWidget: Text("✨", style: TextStyle(fontSize: 20.sp)),
                          ),
                        ),
                      ),
                      title: Text(
                        mat.title,
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, fontFamily: 'SomarSans'),
                      ),
                      subtitle: Text(
                        "${mat.description?.split('\n').first ?? ''}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(Icons.play_circle_fill_rounded, color: themeColor, size: 32.sp),
                      onTap: () => _showUnitPicker(context, mat, themeColor),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
                style: TextStyle(color: const Color(0xFF7C4A27), fontWeight: FontWeight.bold, fontSize: 13.sp),
              ),
            ),
          ],
        ),
        8.verticalSpace,
        SizedBox(
          height: 90.h,
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
                        width: 65.w,
                        margin: EdgeInsets.only(right: 12.w),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 55.r,
                                  height: 55.r,
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
                                    width: 14.r,
                                    height: 14.r,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: isDark ? const Color(0xFF0F172A) : Colors.white, width: 2),
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
