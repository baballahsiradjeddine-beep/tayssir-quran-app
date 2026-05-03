import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/common/core/custom_app_bar.dart';
import 'package:tayssir/debug/app_logger.dart';
import 'package:tayssir/features/chapters/widgets/custom_lesson_widget.dart';
import 'package:tayssir/features/home/presentation/subscribe_section.dart';
import 'package:tayssir/features/units/empty_content_widget.dart';
import 'package:tayssir/providers/user/user_notifier.dart';
import 'package:tayssir/router/app_router.dart';
import 'package:tayssir/services/actions/dialog_service.dart';
import 'package:tayssir/services/sounds/sound_manager.dart';
import 'package:tayssir/providers/special_effect/special_effect_provider.dart';
import 'package:flutter/services.dart';

import '../../providers/data/data_provider.dart';
import '../../providers/data/models/chapter_model.dart';
import '../exercice/presentation/state/exercice_controller.dart';
import '../units/widgets/unit_progress_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:tayssir/common/bayan_background.dart';

class ChaptersScreen extends HookConsumerWidget {
  const ChaptersScreen({super.key, required this.unitId});

  final int unitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userNotifierProvider).valueOrNull;
    final isSub = user?.isSub ?? false;
    final isSoundOn = ref.watch(isSoundEnabledProvider);
    final state = ref.watch(dataProvider);
    final chapters = state.getChaptersByUnitId(unitId);
    final unit = state.getUnitById(unitId);
    final material = state.getMaterialById(unit.materialId);

    if (chapters.isEmpty) {
      return const EmptyContentWidget(
        message: 'سيتم إضافة دروس وآيات لهذه السورة قريباً',
      );
    }
    
    Map<String, List<ChapterModel>> groupChapters(List<ChapterModel> chapters) {
      final Map<String, List<ChapterModel>> groupedChapters = {};
      String? lastDescription;
      int groupCounter = 0;

      for (final chapter in chapters) {
        final currentDescription = (chapter.description == null || chapter.description!.isEmpty) 
            ? null 
            : chapter.description;
        
        if (currentDescription != lastDescription || groupedChapters.isEmpty) {
          final groupKey = currentDescription ?? 'default_group_${groupCounter++}';
          groupedChapters[groupKey] = [chapter];
          lastDescription = currentDescription;
        } else {
          groupedChapters[groupedChapters.keys.last]!.add(chapter);
        }
      }

      return groupedChapters;
    }

    bool isUniqueChapter(String groupTitle) {
      return groupTitle.startsWith('default_group_');
    }

    final groupedChapters = groupChapters(chapters);

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
                      bottom: 32.h // Increased bottom padding
                    ),
                    child: TayssirProgressWidget(
                      name: unit.description,
                      progress: unit.progress,
                      upperText: unit.title,
                      direction: state.getUnitDirection(unitId),
                      startColor: _hexToColor(material.gradiantColorStart),
                      endColor: _hexToColor(material.gradiantColorEnd),
                      imageUrl: material.imageList,
                    ).animate().fadeIn().slideY(begin: -0.1, end: 0),
                  ),
                ),
  
                // 4. Extra Spacer before Chapters
                SliverToBoxAdapter(child: SizedBox(height: 10.h)), // Reduced spacer as new cards are larger
  
                // 5. Chapters List
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final groupTitle = groupedChapters.keys.elementAt(index);
                        final chaptersInGroup = groupedChapters[groupTitle]!;
  
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            isUniqueChapter(groupTitle)
                                ? index == 0
                                    ? const SizedBox(height: 0)
                                    : _buildDivider(state, unitId, chaptersInGroup.first.id, isSub)
                                : _buildGroupHeader(context, state, unitId, chaptersInGroup.first.id, groupTitle, isSub),
                            
                            ...chaptersInGroup.map((chapter) {
                              final isPro = state.isPremiumChapter(chapter.id);
                              return CustomLessonWidget(
                                onPressed: isPro && !isSub
                                    ? () => DialogService.showNeedSubscriptionDialog(context)
                                    : state.isLockedChapter(unitId, chapter.id, isSub)
                                        ? null
                                        : () {
                                            if (isSoundOn) {
                                              SoundService.play('assets/sounds/ui_click_premium.mp3');
                                              HapticFeedback.lightImpact();
                                            }
                                            if (user?.email != null) {
                                              AppLogger.sendLog(
                                                email: user!.email,
                                                content: 'Opened chapter: ${chapter.title}',
                                                type: LogType.chapters,
                                              );
                                            }
                                            ref.read(currentChapterIdProvider.notifier).state = chapter.id;
                                            if (chapter.type == 'lesson') {
                                              context.pushNamed(AppRoutes.lesson.name);
                                            } else {
                                              context.pushReplacementNamed(AppRoutes.exercices.name);
                                            }
                                          },
                                progress: chapter.progress,
                                imageUrl: chapter.image,
                                title: chapter.title,
                                isCurrent: state.isCurrentCHapter(chapter.id, unitId, isSub),
                                isPremium: isPro,
                                forceListLayout: true,
                              ).animate().fadeIn(delay: (index * 80).ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), curve: Curves.easeOutCubic, duration: 400.ms).slideY(begin: 0.1, end: 0);
                            }),
                          ],
                        );
                      },
                      childCount: groupedChapters.length,
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

  Widget _buildDivider(dynamic state, int unitId, int chapterId, bool isSub) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 1.5,
                  decoration: BoxDecoration(
                    gradient: state.isLockedChapter(unitId, chapterId, isSub)
                        ? null
                        : LinearGradient(
                            colors: [
                              Colors.transparent, 
                              const Color(0xFFF59E0B).withOpacity(0.3),
                              Colors.transparent
                            ],
                          ),
                    color: state.isLockedChapter(unitId, chapterId, isSub) 
                        ? (isDark ? const Color(0xFF334155) : const Color(0xFFD3D3D3)) 
                        : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildGroupHeader(BuildContext context, dynamic state, int unitId, int chapterId, String groupTitle, bool isSub) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: _gradientLine(true)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              groupTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: state.isLockedChapter(unitId, chapterId, isSub)
                    ? const Color(0xFF909090)
                    : Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xff1E293B),
                fontSize: 14.sp,
                fontWeight: FontWeight.w900,
                fontFamily: 'SomarSans',
              ),
            ),
          ),
          Expanded(child: _gradientLine(false)),
        ],
      ),
    );
  }

  Widget _gradientLine(bool reverse) {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: reverse 
            ? [Colors.transparent, const Color(0xFFF59E0B).withOpacity(0.6)]
            : [const Color(0xFFF59E0B).withOpacity(0.6), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
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
