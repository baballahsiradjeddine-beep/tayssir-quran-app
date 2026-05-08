import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:tayssir/common/core/custom_app_bar.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/features/onboarding/onboarding_notifier.dart';
import 'package:tayssir/providers/auth/auth_notifier.dart';
import 'package:tayssir/providers/data/data_provider.dart';
import 'package:tayssir/providers/data/models/material_model.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/router/app_router.dart';
import 'package:tayssir/features/home/presentation/view_style.dart';
import 'package:tayssir/features/home/presentation/widgets/course_widget.dart';
import 'package:tayssir/features/home/presentation/subscribe_section.dart';
import 'package:tayssir/common/bayan_background.dart';
import 'package:tayssir/common/quran_base_layout.dart';
import 'package:tayssir/features/ai_planner/presentation/active_plan_overlay.dart';
import 'package:tayssir/utils/enums/auth_state.dart';
import 'package:tayssir/router/bottom_navigation/main_scaffold.dart';

import 'package:tayssir/features/home/presentation/widgets/charity/charity_carousel.dart';
import 'package:tayssir/providers/data/models/charity_model.dart';
import 'package:tayssir/providers/charity/charity_provider.dart';
import 'package:tayssir/features/home/presentation/widgets/progress_map.dart';

class HomeScreen extends StatefulHookConsumerWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ViewStyle _viewStyle = ViewStyle.list;
  String _selectedCategory = 'ahkam';

  @override
  Widget build(BuildContext context) {
    final charityState = ref.watch(charityCampaignsProvider);
    final dataState = ref.watch(dataProvider);
    final authStatus = ref.watch(authNotifierProvider).status;
    final isGuest = authStatus == AuthStatus.unauthenticated || authStatus == AuthStatus.unknown;
    
    final List<MaterialModel> allCourses = dataState.contentData.modules;
    final List<MaterialModel> courses = allCourses.where((m) => m.type == _selectedCategory).toList();
    
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final onboarding = ref.watch(onboardingProvider);

    // Safety net: if there are no courses OR mock data is missing for guests, restore it
    if ((courses.isEmpty || (isGuest && !courses.any((m) => m.id == -999))) && !dataState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(dataProvider.notifier).ensureMockData();
      });
    }


    return BayanBackground(
      child: AppScaffold(
        paddingB: 0,
        paddingX: 0,
        paddingY: 0,
        swipeBackEnabled: true,
        topSafeArea: false,
        floatingActionButton: null,
        extendBody: true,
        bodyBackgroundColor: Colors.transparent,
        body: LayoutBuilder(
          builder: (context, constraints) {
          final double availableWidth = constraints.maxWidth;
          final bool isDesktop = availableWidth > 800;
          const double targetContentWidth = 1050;

          // Standardized centering and alignment logic
          final double horizontalPadding = isDesktop 
              ? (availableWidth > targetContentWidth + 160 ? (availableWidth - targetContentWidth) / 2 : 80.0)
              : 20.w;

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(charityCampaignsProvider);
                  return ref.read(dataProvider.notifier).refreshData();
                },
                color: AppColors.primaryColor,
                child: CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    // 1. Custom AppBar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: horizontalPadding, 
                          right: horizontalPadding, 
                          top: isDesktop ? 30.h : 4.h, 
                          bottom: 0.h
                        ),
                        child: const CustomAppBar(reverse: true),
                      ).animate().fadeIn().slideY(begin: -0.1, end: 0),
                    ),
                    
                    // 2. Charity Carousel (Now at the TOP)
                    charityState.when(
                      data: (campaigns) => SliverToBoxAdapter(
                        child: CharityCarousel(campaigns: campaigns)
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideY(begin: 0.1, end: 0),
                      ),
                      loading: () => SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                      ),
                      error: (err, stack) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                    ),
                    
                    // 3. Materials Header (Simplified without toggle)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20.h),
                        child: Row(
                          children: [
                            Container(
                              width: 6.w,
                              height: 20.h,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.primaryColor : AppColors.warmTitle,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                            12.horizontalSpace,
                            Text(
                              "المحتوى التعليمي :",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : AppColors.warmTitle,
                                fontFamily: 'SomarSans',
                              ),
                            ),
                            const Spacer(),
                            _buildViewToggle(isDark),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                    ),

                    // 4. Spiritual Ward (Moved to top as pure text)
                    const SliverToBoxAdapter(child: SizedBox.shrink()),

                    // 5. Category Tabs (Glassmorphic Navigator)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: horizontalPadding, 
                          right: horizontalPadding, 
                          top: 16.h,
                          bottom: 24.h
                        ),
                        child: _buildGlassNavigator(context, isDark),
                      ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),
                    ),
                    
                    // 5. Materials Content
                    if (dataState.isLoading)
                      SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 80.h, horizontal: horizontalPadding),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 54.sp,
                                  height: 54.sp,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3.w,
                                    valueColor: AlwaysStoppedAnimation<Color>(isDark ? AppColors.primaryColor : AppColors.warmAccent),
                                    backgroundColor: (isDark ? AppColors.primaryColor : AppColors.warmAccent).withOpacity(0.1),
                                  ),
                                ),
                                24.verticalSpace,
                                Text(
                                  "جاري تحميل السور والأجزاء...",
                                  style: TextStyle(
                                    color: isDark ? Colors.white70 : Colors.black45,
                                    fontSize: 14.sp,
                                    fontFamily: 'SomarSans',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else if (courses.isEmpty)
                      SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 80.h, horizontal: horizontalPadding),
                            child: const Text("لا توجد سور متاحة حالياً في مكتبة بيان القرآن"),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 0),
                        sliver: _viewStyle == ViewStyle.grid
                          ? SliverGrid(
                              gridDelegate: isDesktop
                                ? SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 550,
                                    mainAxisSpacing: 16.h,
                                    crossAxisSpacing: 16.w,
                                    mainAxisExtent: 135.h,
                                  )
                                : SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16.h,
                                    crossAxisSpacing: 16.w,
                                    mainAxisExtent: 170.h,
                                  ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildCard(context, ref, courses, index, true),
                                childCount: courses.length,
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => Padding(
                                  padding: EdgeInsets.only(bottom: 16.h),
                                  child: _buildCard(context, ref, courses, index, false),
                                ),
                                childCount: courses.length,
                              ),
                            ),
                      ),
                    
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
              ),
              const ActivePlanOverlay(),
            ],
          );
        },
      ),
    ),
   );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, List<MaterialModel> courses, int index, bool isGrid) {
    final card = CardWidget(
      title: courses[index].title,
      subTitle: courses[index].description ?? 'تتبع حفظك ومراجعتك\nبكل سكينة وإيمان',
      onPressed: () => _navigateToCourse(context, ref, courses[index]),
      startColor: _hexToColor(courses[index].gradiantColorStart),
      endColor: _hexToColor(courses[index].gradiantColorEnd),
      imageList: courses[index].imageList,
      imageGrid: courses[index].imageGrid,
      isGrid: isGrid,
      progress: courses[index].progress,
    ).animate().fadeIn(delay: (300 + index * 50).ms).scale(curve: Curves.easeOutCubic);

    if (index == 0) {
      return Showcase(
        key: tourKeyFirstMaterial,
        description: '',
        showArrow: false,
        tooltipBackgroundColor: Colors.transparent,
        tooltipPosition: TooltipPosition.bottom,
        targetBorderRadius: BorderRadius.circular(24.r),
        overlayOpacity: 0.3,
        disposeOnTap: true,
        onTargetClick: () {
          _navigateToCourse(context, ref, courses[index]);
        },
        child: card,
      );
    }
    return card;
  }

  Widget _buildViewToggle(bool isDark) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : AppColors.warmBorder.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          _ToggleIcon(
            icon: Icons.grid_view_rounded,
            isSelected: _viewStyle == ViewStyle.grid,
            isDark: isDark,
            onTap: () => setState(() => _viewStyle = ViewStyle.grid),
          ),
          _ToggleIcon(
            icon: Icons.view_headline_rounded,
            isSelected: _viewStyle == ViewStyle.list,
            isDark: isDark,
            onTap: () => setState(() => _viewStyle = ViewStyle.list),
          ),
        ],
      ),
    );
  }

  void _navigateToCourse(BuildContext context, WidgetRef ref, MaterialModel course) {
    context.pushNamed(AppRoutes.units.name, pathParameters: {
      'courseId': course.id.toString(),
    });
  }

  // _buildSpiritualWard removed as requested

  Widget _buildGlassNavigator(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(5.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F5F2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFEADBC8).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildGlassTab('quran', 'قرآن', isDark),
          _buildGlassTab('ahkam', 'أحكام', isDark),
          _buildGlassTab('stories', 'قصص', isDark),
        ],
      ),
    );
  }

  Widget _buildGlassTab(String category, String label, bool isDark) {
    final isSelected = _selectedCategory == category;
    
    // Solid, muted colors inspired by 'Sahm Al-Waqf'
    final Color selectedBg = isDark 
        ? AppColors.emerald600 // Solid emerald green for dark mode
        : AppColors.warmTitle; // Solid dark brown for light mode (like Sahm Al-An)
        
    final Color textColor = isSelected 
        ? Colors.white // White text for both modes when selected
        : (isDark ? Colors.white38 : AppColors.warmSubtitle);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 15.sp,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                fontFamily: 'SomarSans',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _hexToColor(String colorStr) {
    String s = colorStr.replaceAll('#', '');
    if (s.length == 6) s = 'FF$s';
    return Color(int.parse(s, radix: 16));
  }
}

class _ToggleIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _ToggleIcon({required this.icon, required this.isSelected, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: isSelected ? (isDark ? AppColors.primaryColor : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: isSelected && !isDark
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: isSelected
              ? (isDark ? Colors.white : AppColors.warmTitle)
              : (isDark ? Colors.white38 : AppColors.warmSubtitle.withOpacity(0.5)),
        ),
      ),
    );
  }
}
