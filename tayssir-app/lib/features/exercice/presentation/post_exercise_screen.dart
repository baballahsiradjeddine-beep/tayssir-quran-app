import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/app_buttons/big_button.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/constants/strings.dart';
import 'package:tayssir/features/exercice/presentation/state/exercice_controller.dart';
import 'package:tayssir/utils/extensions/context.dart';
import 'package:tayssir/services/sounds/sound_manager.dart';
import 'package:tayssir/providers/special_effect/special_effect_provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tayssir/resources/colors/app_colors.dart';

import '../../../resources/resources.dart';
import 'package:tayssir/common/core/app_assets/dynamic_app_asset.dart';
import 'widgets/exercice_app_bar.dart';

class MidResultScreen extends HookConsumerWidget {
  const MidResultScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesState = ref.watch(exercicesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSoundOn = ref.watch(isSoundEnabledProvider);

    useEffect(() {
      if (isSoundOn) {
        if (exercisesState.resultStatus == ResultStatus.good) {
          SoundService.playPoints();
        } else if (exercisesState.resultStatus == ResultStatus.bad) {
          SoundService.playError();
        } else {
          SoundService.playClickPremium();
        }
      }
      return null;
    }, []);

    Color getStatusColor() {
      switch (exercisesState.resultStatus) {
        case ResultStatus.good:
          return AppColors.warmAccent;
        case ResultStatus.bad:
          return const Color(0xFFF87B7C);
        case ResultStatus.average:
          return const Color(0xFFFFB74D);
        default:
          return AppColors.warmAccent;
      }
    }

    String getStatusTitle() {
      switch (exercisesState.resultStatus) {
        case ResultStatus.good:
          return "أداء رائع! ✨";
        case ResultStatus.bad:
          return "لا بأس، حاول مجدداً! 💪";
        case ResultStatus.average:
          return "عمل جيد، استمر! 🚀";
        default:
          return "أحسنت!";
      }
    }

    Widget getMascot() {
      switch (exercisesState.resultStatus) {
        case ResultStatus.good:
          return DynamicAppAsset(
            assetKey: 'refiq_good_exercise',
            fallbackAssetPath: SVGs.refiqGoodExercise,
            type: AppAssetType.svg,
            height: context.isSmallDevice ? 280.h : 350.h,
          );
        case ResultStatus.bad:
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              DynamicAppAsset(
                assetKey: 'refiq_bad_message',
                fallbackAssetPath: SVGs.refiqBadMessage,
                type: AppAssetType.svg,
                height: 85.h, // Reduced from 100.h
              ),
              10.horizontalSpace,
              Flexible(
                child: DynamicAppAsset(
                  assetKey: 'refiq_bad',
                  fallbackAssetPath: SVGs.refiqBad,
                  type: AppAssetType.svg,
                  height: 230.h, // Increased from 200.h
                ),
              ),
            ],
          );
        case ResultStatus.average:
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: DynamicAppAsset(
                  assetKey: 'refiq_average',
                  fallbackAssetPath: SVGs.refiqAverage,
                  type: AppAssetType.svg,
                  height: 230.h, // Increased from 200.h
                ),
              ),
              10.horizontalSpace,
              DynamicAppAsset(
                assetKey: 'refiq_average_message',
                fallbackAssetPath: SVGs.refiqAverageMessage,
                type: AppAssetType.svg,
                height: 85.h, // Reduced from 100.h
              ),
            ],
          );
        default:
          return const SizedBox();
      }
    }

    return AppScaffold(
      onPopScope: () {},
      paddingX: 0,
      paddingY: 0,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 800;
          final maxContentWidth = 1150.0;

          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -150.h,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 450.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          getStatusColor().withOpacity(0.08),
                          getStatusColor().withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60.w : 24.w, vertical: 10.h),
                        child: Column(
                          children: [
                            ExerciceAppBar(
                              exercisesState: exercisesState,
                              onClosePressed: () {
                                ref.read(exercicesProvider.notifier).nextPage();
                                context.pop();
                              },
                            ),
                            
                            const Spacer(flex: 1),
                            
                            Text(
                              getStatusTitle(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isDesktop ? 40.sp : 24.sp,
                                fontWeight: FontWeight.w900,
                                color: getStatusColor(),
                                fontFamily: 'SomarSans',
                                shadows: [
                                  Shadow(
                                    color: getStatusColor().withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              ),
                            ).animate().fadeIn().scale(duration: 400.ms, curve: Curves.easeOutBack),
                            
                            40.verticalSpace,
                            
                            Expanded(
                              flex: 6,
                              child: Center(child: getMascot().animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0)),
                            ),

                            const Spacer(flex: 1),

                            Padding(
                              padding: EdgeInsets.only(bottom: 30.h),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: isDesktop ? 600.0 : double.infinity),
                                  child: Container(
                                    padding: EdgeInsets.all(isDesktop ? 32.w : 24.w),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                      borderRadius: BorderRadius.circular(30.r),
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: BigButton(
                                      text: AppStrings.continueText,
                                      onPressed: () {
                                        ref.read(exercicesProvider.notifier).nextPage();
                                        context.pop();
                                      },
                                    ),
                                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}
