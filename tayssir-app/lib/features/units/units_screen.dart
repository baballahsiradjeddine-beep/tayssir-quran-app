import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/common/core/custom_app_bar.dart';
import 'package:tayssir/features/chapters/widgets/custom_lesson_widget.dart';
import 'package:tayssir/features/units/empty_content_widget.dart';
import 'package:tayssir/providers/user/user_notifier.dart';
import 'package:tayssir/router/app_router.dart';
import 'package:tayssir/services/actions/dialog_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/data/data_provider.dart';
import '../exercice/presentation/state/exercice_controller.dart';
import 'widgets/unit_progress_widget.dart';

import 'package:tayssir/common/bayan_background.dart';

class UnitsScreen extends HookConsumerWidget {
  const UnitsScreen({super.key, required this.courseId});

  final int courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSub = ref.watch(userNotifierProvider).valueOrNull?.isSub ?? false;
    final state = ref.watch(dataProvider);
    final units = state.getUnitsByCourseId(courseId);
    final material = state.getMaterialById(courseId);

    if (units.isEmpty) {
      return const EmptyContentWidget(
        message: 'سيتم اضافة محاور  قريبا',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final bool isDesktop = availableWidth > 800;
        const double targetContentWidth = 1050;

        // Centering and alignment logic
        final double horizontalPadding = isDesktop 
            ? (availableWidth > targetContentWidth + 160 ? (availableWidth - targetContentWidth) / 2 : 80.0)
            : 20.w;

        return BayanBackground(
          child: AppScaffold(
            paddingB: 0,
            paddingX: 0,
            swipeBackEnabled: true,
            topSafeArea: false,
            bodyBackgroundColor: Colors.transparent,
            body: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                // 1. Header (Part of the total scroll)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: horizontalPadding, 
                      right: horizontalPadding, 
                      top: isDesktop ? 30.h : 8.h, 
                      bottom: 16.h
                    ),
                    child: Row(
                      children: [
                        // Actions/Avatar (Right side)
                        const CustomAppBar(reverse: true, showLogo: false, showActions: true),
                        const Spacer(),
                        // Back Button (Left side)
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 44.sp,
                            height: 44.sp,
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                            ),
                            child: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: -0.1, end: 0),
                ),
  
  
                // 3. Progress Widget
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: horizontalPadding, 
                      right: horizontalPadding, 
                      top: 20.h, 
                      bottom: 24.h // Increased from 1.h
                    ),
                    child: TayssirProgressWidget(
                      name: material.description,
                      progress: material.progress,
                      upperText: material.title,
                      direction: material.direction,
                      startColor: _hexToColor(material.gradiantColorStart),
                      endColor: _hexToColor(material.gradiantColorEnd),
                      imageUrl: material.imageList,
                    ).animate().fadeIn().slideY(begin: -0.1, end: 0),
                  ),
                ),
  
                // 4. Spacer before Grid
                SliverToBoxAdapter(child: SizedBox(height: isDesktop ? 24.h : 16.h)),
  
                // 5. Units List
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: Directionality(
                    textDirection: material.direction,
                    child: isDesktop
                      ? SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 3.5, // Adjusted for new card aspect
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final isCurrent = state.isCurrentUnit(units[index].id, courseId);
                              final isPremiumUnit = state.isPremiumUnit(units[index].id);
                              return CustomLessonWidget(
                                onPressed: isPremiumUnit && !isSub
                                    ? () => DialogService.showNeedSubscriptionDialog(context)
                                    : () {
                                        ref.read(currentUnitIdProvider.notifier).state = units[index].id;
                                        context.pushNamed(
                                          AppRoutes.chapters.name,
                                          pathParameters: {
                                            'courseId': courseId.toString(),
                                            'unitId': units[index].id.toString()
                                          },
                                        );
                                      },
                                imageUrl: units[index].image,
                                progress: units[index].progress,
                                title: units[index].title,
                                isPremium: isPremiumUnit,
                                isCurrent: isCurrent,
                              ).animate().fadeIn(delay: (index * 60).ms).scale(
                                begin: const Offset(0.9, 0.9), end: const Offset(1, 1),
                                curve: Curves.easeOutCubic, duration: 350.ms);
                            },
                            childCount: units.length,
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final isCurrent = state.isCurrentUnit(units[index].id, courseId);
                              final isPremiumUnit = state.isPremiumUnit(units[index].id);
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.h), // Reduced as card has internal margin
                                child: CustomLessonWidget(
                                  onPressed: isPremiumUnit && !isSub
                                      ? () => DialogService.showNeedSubscriptionDialog(context)
                                      : () {
                                          ref.read(currentUnitIdProvider.notifier).state = units[index].id;
                                          context.pushNamed(
                                            AppRoutes.chapters.name,
                                            pathParameters: {
                                              'courseId': courseId.toString(),
                                              'unitId': units[index].id.toString()
                                            },
                                          );
                                        },
                                  imageUrl: units[index].image,
                                  progress: units[index].progress,
                                  title: units[index].title,
                                  isPremium: isPremiumUnit,
                                  isCurrent: isCurrent,
                                ).animate().fadeIn(delay: (index * 80).ms).scale(
                                  begin: const Offset(0.95, 0.95), end: const Offset(1, 1),
                                  curve: Curves.easeOutCubic, duration: 400.ms).slideY(begin: 0.1, end: 0),
                              );
                            },
                            childCount: units.length,
                          ),
                        ),
                  ),
                ),
  
                SliverToBoxAdapter(child: 120.verticalSpace),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
}
