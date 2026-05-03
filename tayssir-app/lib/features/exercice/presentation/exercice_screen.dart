import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/blur_overlay_widget.dart';
import 'package:tayssir/features/chapters/pre_exercise_screen.dart';
import 'package:tayssir/providers/data/data_provider.dart';
import 'package:tayssir/services/actions/bottom_sheet_service.dart';
import 'package:tayssir/features/exercice/presentation/state/exercice_controller.dart';
import 'package:tayssir/services/actions/snack_bar_service.dart';
import 'package:tayssir/utils/extensions/async_value.dart';
import 'package:video_player/video_player.dart';

import '../../../router/app_router.dart';
import 'state/video_provider.dart';
import 'widgets/exercice_app_bar.dart';
import 'exercise_type_view.dart';
import 'widgets/video/video_view_portrait_widget.dart';

import 'package:tayssir/common/bayan_background.dart';

class ExerciceScreen extends HookConsumerWidget {
  const ExerciceScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesState = ref.watch(exercicesProvider);
    final videoState = ref.watch(videoProvider);
    final size = MediaQuery.of(context).size;
    final progress = useState<double>(0.0);
    final isLoading = useState(true);

    final slideAnimationController = useAnimationController(
      duration: const Duration(milliseconds: 700),
    );
    ref.listen(exercicesProvider.select((v) => v.reportingStatus), (prv, nxt) {
      nxt.handleSideThings(context, () {
        SnackBarService.showSuccessToast(
            'تم إرسال التقرير بنجاح, سنقوم بمراجعته');
      });
    });

    useEffect(() {
      final timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        progress.value += 0.05;
        if (progress.value >= 1.0) {
          timer.cancel();

          slideAnimationController.forward().then((_) {
            isLoading.value = false;

            slideAnimationController.reset();

            Future.delayed(const Duration(milliseconds: 50), () {
              slideAnimationController.forward();
            });
          });
        }
      });

      return () => timer.cancel();
    }, []);

    if (exercisesState.exercises.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final slideInAnimation = Tween<Offset>(
      // move from left to center
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: slideAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    final slideOutAnimation = Tween<Offset>(
      // move from center to right
      begin: Offset.zero,
      end: const Offset(1.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: slideAnimationController,
        curve: Curves.easeInCubic,
      ),
    );

    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    
    // For review mode, we don't have a specific chapter/unit
    final int? unitId = exercisesState.isReviewMode 
        ? null 
        : ref.watch(dataProvider).getChapterById(exercisesState.currentExercise.chapterId).unitId;

    useEffect(() {
      return () {
        // Reset review flags when leaving
        Future.microtask(() {
          ref.read(isReviewProvider.notifier).state = false;
          ref.read(isDebugReviewProvider.notifier).state = false;
        });
      };
    }, []);

    handleLeaving() {
      final currentExercise = ref.read(exercicesProvider).currentExercise;
      final chapter = ref.read(dataProvider).getChapterById(currentExercise.chapterId);
      final unitIdValue = chapter.unitId;
      
      // We need to find the courseId that owns this unit
      int? courseIdValue;
      final materials = ref.read(dataProvider).contentData.modules;
      for (final material in materials) {
        final units = ref.read(dataProvider).getUnitsByCourseId(material.id);
        if (units.any((u) => u.id == unitIdValue)) {
          courseIdValue = material.id;
          break;
        }
      }

      BottomSheetService.showLeaveBottomSheet(context, (ctx) async {
        Navigator.of(ctx).pop();
        await Future.delayed(const Duration(milliseconds: 50));
        
        if (context.mounted) {
          ref.read(isReviewProvider.notifier).state = false;
          ref.read(isDebugReviewProvider.notifier).state = false;
          
          if (courseIdValue != null && unitIdValue != 0) {
            context.goNamed(
              AppRoutes.chapters.name,
              pathParameters: {
                'courseId': courseIdValue.toString(),
                'unitId': unitIdValue.toString(),
              },
            );
          } else {
            context.goNamed(AppRoutes.home.name);
          }
        }
      }, (ctx) {
        Navigator.of(ctx).pop();
      });
    }

    return BayanBackground(
      child: Stack(
        fit: StackFit.expand,
        children: [
          SlideTransition(
            position: slideInAnimation,
            child: Visibility(
              visible: !isLoading.value,
              maintainState: true,
              maintainAnimation: true,
              maintainSize: true,
              child: BlurOverlayWidget(
                onPopScope: () {
                  if (exercisesState.isShowVideo) {
                    // ref.read(exercicesProvider.notifier).hideVideo();
                    // ref.read(exercicesProvider.notifier).nextExerise(context);
                  } else {
                    handleLeaving();
                  }
                },
                padding: EdgeInsets.zero,
                showOverlay: exercisesState.isShowVideo,
                overlayContent:
                    OrientationBuilder(builder: (context, orientation) {
                  if (orientation == Orientation.portrait) {
                    return VideoViewPortraitWidget(size: size);
                  } else {
                    return Column(
                      children: [
                        Expanded(
                          child: VideoPlayer(videoState.player!),
                        )
                      ],
                    );
                  }
                }),
                child: Column(
                  children: [
                    ExerciceAppBar(
                      exercisesState: exercisesState,
                      onClosePressed: () {
                        handleLeaving();
                      },
                    ),
                    5.verticalSpace,
                    Expanded(
                      child: Directionality(
                        textDirection:
                            exercisesState.currentExercise.currentDirection,
                        child: PageView(
                          controller: exercisesState.pageController,
                          onPageChanged: (index) {},
                          physics: const NeverScrollableScrollPhysics(),
                          children: exercisesState.exercises
                              .map((e) => ExerciseView(exercise: e))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SlideTransition(
            position: slideOutAnimation,
            child: Visibility(
              visible: isLoading.value,
              maintainState: true,
              maintainAnimation: true,
              maintainSize: true,
              child: PreExerciseScreen(
                progress: progress.value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
