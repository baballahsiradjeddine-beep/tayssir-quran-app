import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/app_buttons/big_button.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/constants/strings.dart';
import 'package:tayssir/features/exercice/presentation/widgets/results/result_stats_widget.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/resources/resources.dart';
import 'package:tayssir/router/app_router.dart';
import 'package:tayssir/common/bayan_background.dart';
import 'package:tayssir/common/core/app_assets/dynamic_app_asset.dart';
import 'package:tayssir/features/onboarding/onboarding_notifier.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tayssir/services/sounds/sound_manager.dart';
import 'package:tayssir/providers/settings/settings_provider.dart';
import 'package:tayssir/providers/data/data_provider.dart';

class LessonResultScreen extends HookConsumerWidget {
  final int chapterId;
  final int points;
  final Duration elapsedTime;

  const LessonResultScreen({
    super.key,
    required this.chapterId,
    required this.points,
    required this.elapsedTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSoundOn = ref.watch(isSoundEnabledProvider);

    useEffect(() {
      if (isSoundOn) {
        SoundService.playLevelComplete();
      }
      return null;
    }, []);

    String formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      return "$twoDigitMinutes:$twoDigitSeconds";
    }

    return BayanBackground(
      child: AppScaffold(
        onPopScope: () {},
        paddingX: 0,
        paddingY: 0,
        bodyBackgroundColor: Colors.transparent,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 800;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1150),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60.w : 24.w),
                  child: Column(
                    children: [
                      const Spacer(flex: 1),
                      
                      Text(
                        'أحسنت! لقد أكملت الدرس',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isDesktop ? 42.sp : 26.sp,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'SomarSans',
                        ),
                      ).animate().fadeIn().slideY(begin: -0.2, end: 0, curve: Curves.easeOutBack),
                      
                      const Spacer(flex: 2),
                      
                      // mascot
                      Center(
                        child: DynamicAppAsset(
                          assetKey: 'mascot_happy', // Fallback to a happy mascot
                          fallbackAssetPath: SVGs.icResultCheck,
                          type: AppAssetType.svg,
                          height: isDesktop ? 180.h : 160.h,
                        ).animate().scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut, duration: 1200.ms),
                      ),
                      
                      const Spacer(flex: 2),
                      
                      // stats cards section
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 850),
                        child: Row(
                          children: [
                            Expanded(
                              child: ResultStatsWidget(
                                value: points.toString(),
                                title: 'النقاط',
                                icon: SVGs.icGem,
                                startColor: AppColors.goldColorLight,
                                endColor: AppColors.goldColor,
                              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
                            ),
                            16.horizontalSpace,
                            Expanded(
                              child: ResultStatsWidget(
                                value: formatDuration(elapsedTime),
                                title: 'الوقت',
                                icon: SVGs.icTime,
                                startColor: const Color(0xFF10B981),
                                endColor: const Color(0xFF059669),
                              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0),
                            ),
                          ],
                        ),
                      ),
                      
                      const Spacer(flex: 3),
                      
                      Padding(
                        padding: EdgeInsets.only(bottom: 40.h),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: BigButton(
                              text: 'المتابعة',
                              onPressed: () {
                                // Find next chapter logic or go back to chapters
                                final dataState = ref.read(dataProvider);
                                final chapter = dataState.getChapterById(chapterId);
                                final unitId = chapter.unitId;
                                final chaptersInUnit = dataState.getChaptersByUnit(unitId);
                                
                                int currentIndex = chaptersInUnit.indexWhere((c) => c.id == chapterId);
                                if (currentIndex != -1 && currentIndex < chaptersInUnit.length - 1) {
                                  // Go to next chapter
                                  final nextChapter = chaptersInUnit[currentIndex + 1];
                                  context.pushReplacementNamed(
                                    AppRoutes.chapters.name, // Usually we go back to list, or auto-start next?
                                    // Actually, standard behavior is go back to chapters list to see progress
                                    pathParameters: {
                                      'courseId': dataState.getUnitById(unitId).materialId.toString(),
                                      'unitId': unitId.toString(),
                                    },
                                  );
                                } else {
                                  context.goNamed(AppRoutes.home.name);
                                }
                              },
                            ).animate().fadeIn(delay: 1100.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
