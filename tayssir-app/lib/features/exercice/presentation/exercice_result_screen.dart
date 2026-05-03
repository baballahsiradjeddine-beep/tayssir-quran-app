import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/app_buttons/big_button.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/constants/strings.dart';
import 'package:tayssir/debug/app_logger.dart';
import 'package:tayssir/features/exercice/presentation/state/exercice_controller.dart';
import 'package:tayssir/providers/data/models/chapter_model.dart';
import 'package:tayssir/providers/user/user_notifier.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/utils/extensions/context.dart';
import 'package:tayssir/utils/extensions/strings.dart';
import '../../../providers/data/data_provider.dart';
import '../../../resources/resources.dart';
import '../../../router/app_router.dart';
import 'package:tayssir/features/streaks/presentation/streak_notifier.dart';
import 'package:tayssir/common/core/app_assets/dynamic_app_asset.dart';
import 'package:tayssir/features/onboarding/onboarding_notifier.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tayssir/services/sounds/sound_manager.dart';
import 'package:tayssir/providers/special_effect/special_effect_provider.dart';
import '../../ai_planner/state/ai_planner_notifier.dart';
import 'widgets/results/result_stats_widget.dart';

import 'package:tayssir/common/bayan_background.dart';

class ExerciceResultScreen extends HookConsumerWidget {
  const ExerciceResultScreen({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesState = ref.watch(exercicesProvider);
    final dataState = ref.watch(dataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSoundOn = ref.watch(isSoundEnabledProvider);

    useEffect(() {
      if (isSoundOn) {
        SoundService.playLevelComplete();
      }
      return null;
    }, []);

    final isComplete = exercisesState.bestProgress == 100;
    final user = ref.watch(userNotifierProvider).valueOrNull;
    final firstChapterId = exercisesState.exercises.isNotEmpty
        ? exercisesState.exercises.first.chapterId
        : -1;
    final visib = dataState.getChapterVisibility(firstChapterId);

    String getTitle() {
      switch (visib) {
        case ChapterVisibility.fresh: return 'عدد النقاط';
        case ChapterVisibility.current:
        case ChapterVisibility.done:
          return isComplete ? 'الإجابات الصحيحة' : 'النقاط المحصلة';
        default: return 'عدد النقاط';
      }
    }

    String getValue() {
      switch (visib) {
        case ChapterVisibility.fresh: return exercisesState.points.toString();
        case ChapterVisibility.current:
        case ChapterVisibility.done:
          return isComplete 
              ? '${exercisesState.numberofCorrectAnswers}/${exercisesState.exercises.length}'
              : exercisesState.resultPoints.toString();
        default: return exercisesState.points.toString();
      }
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
  
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent, // Let BayanBackground shine
                ),
                child: Stack(
                  children: [
                    // Premium Background Pattern or Glows
                    Positioned(
                      top: -100.h,
                      left: -50.w,
                      child: Container(
                      width: 400.w,
                      height: 400.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor.withOpacity(0.05),
                      ),
                    ).animate().scale(duration: 2.seconds, curve: Curves.easeInOut),
                  ),
                  
                  SafeArea(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1150),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60.w : 24.w),
                            child: Column(
                              children: [
                              const Spacer(flex: 1),
                              
                              Text(
                                exercisesState.accuracy.resultText(),
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
                                  assetKey: exercisesState.accuracy.resultAssetKey(),
                                  fallbackAssetPath: exercisesState.accuracy.resultIcon(),
                                  type: AppAssetType.svg,
                                  height: isDesktop ? 180.h : 160.h,
                                ).animate().scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut, duration: 1200.ms),
                              ),
                              
                              const Spacer(flex: 2),
                              
                              // stats cards section
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 850),
                                child: isDesktop 
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: ResultStatsWidget(
                                            value: getValue(),
                                            title: getTitle(),
                                            icon: isComplete ? SVGs.icResultCheck : SVGs.icGem,
                                          startColor: AppColors.goldColorLight,
                                          endColor: AppColors.goldColor,
                                          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
                                        ),
                                        24.horizontalSpace,
                                        Expanded(
                                          child: ResultStatsWidget(
                                            value: exercisesState.elapsedTime.toTime,
                                            title: 'الوقت',
                                            icon: SVGs.icTime,
                                            startColor: const Color(0xFF10B981),
                                            endColor: const Color(0xFF059669),
                                          ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0),
                                        ),
                                        24.horizontalSpace,
                                        Expanded(
                                          child: ResultStatsWidget(
                                            value: exercisesState.accuracy.toPercentage(),
                                            title: 'الدقة',
                                            icon: SVGs.icPrecision,
                                            startColor: const Color(0xFFF43F5E),
                                            endColor: const Color(0xFFE11D48),
                                          ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.1, end: 0),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ResultStatsWidget(
                                          value: getValue(),
                                          title: getTitle(),
                                          icon: isComplete ? SVGs.icResultCheck : SVGs.icGem,
                                          startColor: AppColors.goldColorLight,
                                          endColor: AppColors.goldColor,
                                        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
                                        16.verticalSpace,
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ResultStatsWidget(
                                                value: exercisesState.elapsedTime.toTime,
                                                title: 'الوقت',
                                                icon: SVGs.icTime,
                                                startColor: const Color(0xFF10B981),
                                                endColor: const Color(0xFF059669),
                                              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0),
                                            ),
                                            16.horizontalSpace,
                                            Expanded(
                                              child: ResultStatsWidget(
                                                value: exercisesState.accuracy.toPercentage(),
                                                title: 'الدقة',
                                                icon: SVGs.icPrecision,
                                                startColor: const Color(0xFFF43F5E),
                                                endColor: const Color(0xFFE11D48),
                                              ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.1, end: 0),
                                            ),
                                          ],
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
                                      text: AppStrings.continueText,
                                      onPressed: () async {
                                        final unitId = dataState
                                            .getChapterById(firstChapterId)
                                            .unitId;
                                        final streakState = ref.read(streakNotifierProvider).value;
                                        final bool didStreakIncrease =
                                            streakState?.streakIncreasedToday ?? false;

                                        await Future.delayed(const Duration(milliseconds: 100));

                                        if (context.mounted) {
                                          final isPlannerSession = ref.read(isPlannerSessionActiveProvider);
                                          if (isPlannerSession) {
                                            ref.read(isPlannerSessionActiveProvider.notifier).state = false;
                                            ref.read(isFromAiPlannerProvider.notifier).state = true;
                                            if (firstChapterId != -1) {
                                              ref.read(aiPlannerProvider.notifier).markChapterTaskDone(firstChapterId, 'exercise');
                                            }
                                            context.goNamed(AppRoutes.home.name);
                                            return;
                                          }
                                          if (exercisesState.isReviewMode) {
                                            context.goNamed(AppRoutes.home.name);
                                            return;
                                          }
                                          if (firstChapterId == -999) {
                                            await ref.read(onboardingProvider.notifier).setTourStep(99);
                                            if (context.mounted) {
                                              context.goNamed(AppRoutes.home.name);
                                            }
                                            return;
                                          }
                                          if (user?.email != null) {
                                            await AppLogger.sendLog(
                                              email: user!.email,
                                              content: 'Finished exercise: ${dataState.getChapterById(firstChapterId).title} Accuracy: ${exercisesState.accuracy.toPercentage()}',
                                              type: LogType.chapters,
                                            );
                                          }

                                          if (context.mounted) {
                                            if (didStreakIncrease && streakState != null) {
                                              context.pushReplacementNamed(
                                                AppRoutes.streak.name,
                                                extra: {
                                                  'streak': streakState,
                                                  'unitId': unitId,
                                                },
                                              );
                                            } else {
                                              // Properly resolve courseId and unitId
                                              final units = ref.read(dataProvider).contentData.units;
                                              final unit = units.firstWhere((u) => u.id == unitId);
                                              final courseId = unit.materialId;

                                              context.pushReplacementNamed(
                                                AppRoutes.chapters.name,
                                                pathParameters: {
                                                  'courseId': courseId.toString(),
                                                  'unitId': unitId.toString(),
                                                },
                                              );
                                            }
                                          }
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
                    ),
                  ),
                ),
                ],
              ),
            );
          }
        )));
  }
}
