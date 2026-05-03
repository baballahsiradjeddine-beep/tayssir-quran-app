import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/features/home/presentation/subscribe_section.dart';
import 'package:tayssir/features/tools/common/state/tools_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tayssir/providers/user/user_notifier.dart';
import 'package:go_router/go_router.dart';
import 'package:tayssir/resources/colors/app_colors.dart';

import '../../../common/core/app_scaffold.dart';
import '../../../common/core/custom_app_bar.dart';

import '../home/presentation/widgets/course_widget.dart';

class ToolsScreen extends ConsumerWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tools = ref.watch(toolsProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      topSafeArea: false,
      extendBody: true,
      bodyBackgroundColor: Colors.transparent,
      paddingX: 0,
      paddingB: 0,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double availableWidth = constraints.maxWidth;
          final bool isDesktop = availableWidth > 800;
          const double targetContentWidth = 1050;

          // Standardized centering and alignment logic
          final double horizontalPadding = isDesktop 
              ? (availableWidth > targetContentWidth + 160 ? (availableWidth - targetContentWidth) / 2 : 80.0)
              : 20.w;

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(toolsProvider),
            color: const Color(0xFF10B981),
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                // 1. App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: horizontalPadding, 
                      right: horizontalPadding, 
                      top: isDesktop ? 30.h : 8.h, 
                      bottom: 16.h
                    ),
                    child: const CustomAppBar(reverse: true),
                  ).animate().fadeIn().slideY(begin: -0.1, end: 0),
                ),

                // 2. Hero Banner Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: const SubscribeSection(),
                  ),
                ),

                // 3. Section Header (Simplified without toggle)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20.h),
                    child: Row(
                      children: [
                        Container(
                          width: 8.w,
                          height: 24.h,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        12.horizontalSpace,
                        Text(
                          'الأدوات المتاحة :',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppColors.textBlack,
                            fontFamily: 'SomarSans',
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                ),

                // 4. Tools Content (Always Grid with list images as requested)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 0),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: isDesktop ? 550 : 200,
                      mainAxisSpacing: 16.w,
                      crossAxisSpacing: 16.w,
                      mainAxisExtent: isDesktop ? 135.h : 170.h,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => CardWidget(
                        title: tools[index].name,
                        subTitle: tools[index].description,
                        onPressed: () => context.pushNamed(tools[index].pathName),
                        startColor: tools[index].startColor,
                        endColor: tools[index].endColor,
                        // Using list images for grid cards as requested
                        imageList: tools[index].toolImage.list,
                        imageGrid: tools[index].toolImage.list,
                        isGrid: true,
                        toolImage: tools[index].toolImage,
                      ).animate().fadeIn(delay: (index * 50).ms).scale(curve: Curves.easeOutCubic),
                      childCount: tools.length,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          );
        },
      ),
    );
  }
}
