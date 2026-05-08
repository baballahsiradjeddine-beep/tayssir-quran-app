import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/common/core/custom_app_bar.dart';
import 'package:tayssir/debug/app_logger.dart';
import 'package:tayssir/features/chapters/widgets/roadmap_node.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(dataProvider);
    final chapters = state.getChaptersByUnitId(unitId);
    final unit = state.getUnitById(unitId);
    final material = state.getMaterialById(unit.materialId);

    final startColor = _hexToColor(material.gradiantColorStart);
    final endColor = _hexToColor(material.gradiantColorEnd);

    if (chapters.isEmpty) {
      return const EmptyContentWidget(
        message: 'سيتم إضافة دروس وآيات لهذه السورة قريباً',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final bool isDesktop = availableWidth > 900;
        final double targetContentWidth = isDesktop ? 1000.w : 600; 

        final double horizontalPadding = isDesktop 
            ? (availableWidth - targetContentWidth) / 2 
            : 20.w;

        return BayanBackground(
          child: AppScaffold(
            paddingB: 0,
            paddingX: 0,
            swipeBackEnabled: true,
            topSafeArea: false,
            bodyBackgroundColor: Colors.transparent,
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Premium Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: isDesktop ? 60.w : 20.w, 
                      right: isDesktop ? 60.w : 20.w, 
                      top: isDesktop ? 40.h : 6.h, 
                      bottom: 20.h
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const CustomAppBar(reverse: true, showLogo: false, showActions: true),
                            const Spacer(),
                            _buildBackButton(context),
                          ],
                        ),
                        30.verticalSpace,
                        _buildPremiumTitleSection(unit, isDark, isDesktop, startColor),
                      ],
                    ),
                  ),
                ),

                // 2. Roadmap Path
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final chapter = chapters[index];
                        final isPro = state.isPremiumChapter(chapter.id);
                        final isLocked = state.isLockedChapter(unitId, chapter.id, isSub);
                        final isCurrent = state.isCurrentCHapter(chapter.id, unitId, isSub);
                        
                        final double alignment = _getAlignment(index, isDesktop);
                        final double nodeHeight = isDesktop ? 220.h : 150.h;

                        return SizedBox(
                          height: nodeHeight,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              if (index > 0)
                                CustomPaint(
                                  size: Size(targetContentWidth, nodeHeight),
                                  painter: RoadmapPathPainter(
                                    prevAlignment: _getAlignment(index - 1, isDesktop),
                                    currentAlignment: alignment,
                                    color: isDark 
                                        ? (isLocked ? Colors.white10 : startColor)
                                        : (isLocked ? Colors.black.withOpacity(0.05) : AppColors.warmTitle.withOpacity(0.15)),
                                    isDashed: isLocked,
                                    isDesktop: isDesktop,
                                  ),
                                ),
                              
                              Align(
                                alignment: Alignment(alignment, 0),
                                child: Transform.scale(
                                  scale: isDesktop ? 1.3 : 1.0,
                                  child: RoadmapNode(
                                    title: chapter.title,
                                    imageUrl: chapter.image,
                                    progress: chapter.progress,
                                    isLocked: isLocked,
                                    isCurrent: isCurrent,
                                    isPremium: isPro,
                                    startColor: startColor,
                                    endColor: endColor,
                                    onTap: () => _onChapterTap(context, ref, state, chapter, user, isPro, isSub, isSoundOn),
                                  ).animate().fadeIn(delay: (index * 50).ms).scale(duration: 400.ms),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: chapters.length,
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: 150.verticalSpace),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumTitleSection(dynamic unit, bool isDark, bool isDesktop, Color accentColor) {
    return Column(
      children: [
        Text(
          unit.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? 48.sp : 26.sp,
            fontWeight: FontWeight.w900,
            fontFamily: 'SomarSans',
            color: isDark ? Colors.white : AppColors.warmTitle,
            height: 1.1,
          ),
        ).animate().fadeIn().slideY(begin: 0.2, end: 0),
        20.verticalSpace,
        Container(
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: isDark ? accentColor.withOpacity(0.1) : AppColors.warmTitle.withOpacity(0.06),
            borderRadius: BorderRadius.circular(40.r),
            border: Border.all(
              color: isDark ? accentColor.withOpacity(0.2) : AppColors.warmTitle.withOpacity(0.1), 
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome_rounded, size: 20.sp, color: isDark ? accentColor : AppColors.warmTitle),
              14.horizontalSpace,
              Text(
                'المستوى: ${unit.description}',
                style: TextStyle(
                  fontSize: isDesktop ? 20.sp : 14.sp,
                  color: isDark ? accentColor : AppColors.warmTitle,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'SomarSans',
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).scale(),
      ],
    );
  }

  double _getAlignment(int index, bool isDesktop) {
    final double amplitude = isDesktop ? 0.9 : 0.7;
    final pattern = [0.0, 0.4 * amplitude, 1.0 * amplitude, 0.4 * amplitude, 0.0, -0.4 * amplitude, -1.0 * amplitude, -0.4 * amplitude];
    return pattern[index % pattern.length];
  }

  Widget _buildBackButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        width: 54.sp,
        height: 54.sp,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
             BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : AppColors.warmBorder,
            width: 1,
          ),
        ),
        child: Icon(Icons.arrow_back_ios_new_rounded, size: 22.sp),
      ),
    );
  }

  void _onChapterTap(BuildContext context, WidgetRef ref, dynamic state, ChapterModel chapter, dynamic user, bool isPro, bool isSub, bool isSoundOn) {
    if (isPro && !isSub) {
      DialogService.showNeedSubscriptionDialog(context);
      return;
    }
    if (isSoundOn) {
      SoundService.play('assets/sounds/ui_click_premium.mp3');
      HapticFeedback.lightImpact();
    }
    ref.read(currentChapterIdProvider.notifier).state = chapter.id;
    if (chapter.type == 'lesson') {
      context.pushNamed(AppRoutes.lesson.name);
    } else {
      context.pushReplacementNamed(AppRoutes.exercices.name);
    }
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}

class RoadmapPathPainter extends CustomPainter {
  final double prevAlignment;
  final double currentAlignment;
  final Color color;
  final bool isDashed;
  final bool isDesktop;

  RoadmapPathPainter({
    required this.prevAlignment,
    required this.currentAlignment,
    required this.color,
    required this.isDashed,
    required this.isDesktop,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Highly subtle opacity for the path
    final pathOpacity = isDashed ? 0.15 : 0.35;
    
    final paint = Paint()
      ..color = color.withOpacity(pathOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isDesktop ? 2.5 : 2.0
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isDesktop ? 6.0 : 4.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final double xMultiplier = isDesktop ? 2.1 : 2.5;
    final startX = size.width / 2 + (prevAlignment * (size.width / xMultiplier));
    final endX = size.width / 2 + (currentAlignment * (size.width / xMultiplier));

    // Further increased vertical offset to completely avoid text below nodes
    final double nodeRadiusOffset = isDesktop ? 100.h : 75.h;
    
    final path = Path();
    path.moveTo(startX, -size.height / 2 + nodeRadiusOffset); 
    
    path.cubicTo(
      startX, size.height * 0.05,
      endX, size.height * 0.05,
      endX, size.height / 2 - nodeRadiusOffset,
    );

    if (isDashed) {
      _drawDottedPath(canvas, path, paint);
    } else {
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, paint);
    }
  }

  void _drawDottedPath(Canvas canvas, Path path, Paint paint) {
    final double dotRadius = isDesktop ? 2.0 : 1.5;
    const double spacing = 16.0;
    
    for (final pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final tangent = pathMetric.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, dotRadius, paint);
        }
        distance += spacing;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
