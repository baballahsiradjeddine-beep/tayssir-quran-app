import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tayssir/common/app_buttons/big_button.dart';
import 'package:tayssir/features/exercice/presentation/view/question_type_widget.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/common/bayan_background.dart';
import 'package:tayssir/features/exercice/presentation/widgets/exercise_header.dart';
import 'package:tayssir/providers/settings/settings_provider.dart';
import 'package:tayssir/features/chapters/pre_exercise_screen.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/features/exercice/presentation/state/exercice_controller.dart';
import 'package:tayssir/providers/data/data_provider.dart';
import 'package:tayssir/providers/user/user_notifier.dart';
import 'package:tayssir/common/core/shield_badge.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';

class LessonScreen extends HookConsumerWidget {
  const LessonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapterId = ref.watch(currentChapterIdProvider);
    final dataState = ref.watch(dataProvider);
    final chapter = dataState.getChapterById(chapterId);
    
    final currentStep = useState(0);
    final stopwatch = useState(Stopwatch());
    
    useEffect(() {
      stopwatch.value.start();
      return () => stopwatch.value.stop();
    }, []);
    final slides = chapter.content ?? [];
    final totalSteps = slides.length;
    final progressValue = useState<double>(0.0);
    final isLoading = useState(true);

    final slideAnimationController = useAnimationController(
      duration: const Duration(milliseconds: 700),
    );

    useEffect(() {
      final timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        progressValue.value += 0.05;
        if (progressValue.value >= 1.0) {
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

    final slideInAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: slideAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    final slideOutAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: slideAnimationController,
        curve: Curves.easeInCubic,
      ),
    );

    final pageController = usePageController(initialPage: currentStep.value);

    // Sync PageView with currentStep
    useEffect(() {
      if (pageController.hasClients && pageController.page?.round() != currentStep.value) {
        pageController.animateToPage(
          currentStep.value,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
      return null;
    }, [currentStep.value]);

    final progress = totalSteps > 0 ? (currentStep.value + 1) / totalSteps : 0.0;

    return BayanBackground(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Content Layer
          SlideTransition(
            position: slideInAnimation,
            child: Visibility(
              visible: !isLoading.value,
              maintainState: true,
              child: AppScaffold(
                paddingX: 0,
                paddingB: 0,
                body: Column(
                  children: [
                    // AppBar
                    _LessonAppBar(
                      title: chapter.title,
                      progress: progress,
                      onClose: () => context.pop(),
                    ),

                    // Content Area
                    Expanded(
                      child: totalSteps > 0 
                        ? PageView.builder(
                            itemCount: totalSteps,
                            physics: const NeverScrollableScrollPhysics(),
                            onPageChanged: (index) => currentStep.value = index,
                            itemBuilder: (context, index) {
                              return SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    40.verticalSpace,
                                    // Custom Lesson Header (Constrained and Centered)
                                    Center(
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 1000.0),
                                        child: _LessonHeader(title: chapter.title),
                                      ),
                                    ),
                                    50.verticalSpace,
                                    _buildSlideContent(slides[index]),
                                    100.verticalSpace,
                                  ],
                                ),
                              );
                            },
                            controller: pageController,
                          )
                        : const Center(child: Text('لا يوجد محتوى لهذا الدرس', style: TextStyle(color: Colors.white))),
                    ),

                    // Bottom Action
                    Padding(
                      padding: EdgeInsets.only(bottom: 30.h, top: 10.h, left: 20.w, right: 20.w),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 1000.0),
                          child: BigButton(
                            text: currentStep.value < totalSteps - 1 ? 'تابع' : 'إنهاء الدرس',
                            onPressed: () async {
                              if (currentStep.value < totalSteps - 1) {
                                currentStep.value++;
                              } else {
                                // Final Submission logic
                                final elapsed = stopwatch.value.elapsed;
                                stopwatch.value.stop();
                                
                                // Show loading state if needed, or just submit
                                final totalPoints = totalSteps; // 1 point per slide
                                
                                await ref.read(dataProvider.notifier).submitAnswers(
                                  [], // No answers for lessons
                                  chapter.id,
                                  totalSlides: totalPoints,
                                );
                                
                                if (context.mounted) {
                                  context.pushReplacementNamed(
                                    AppRoutes.lessonResults.name,
                                    extra: {
                                      'chapterId': chapter.id,
                                      'points': totalPoints,
                                      'elapsedTime': elapsed,
                                    },
                                  );
                                }
                              }
                            },
                          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading Layer
          SlideTransition(
            position: slideOutAnimation,
            child: Visibility(
              visible: isLoading.value,
              child: PreExerciseScreen(
                progress: progressValue.value,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideContent(Map<String, dynamic> slide) {
    final elements = slide['elements'] as List<dynamic>? ?? [];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1000.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ...elements.map((el) => _LessonElementWidget(element: el as Map<String, dynamic>)).toList(),
        ],
      ),
    );
  }
}

class _LessonHeader extends ConsumerWidget {
  final String title;
  const _LessonHeader({required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userNotifierProvider).valueOrNull;
    final badgeColor = user?.badge?.color;
    final themeColor = badgeColor != null
        ? Color(int.parse(badgeColor.replaceAll('#', '0xFF')))
        : const Color(0xFF10B981);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShieldBadge(
            userAvatarUrl: user?.completeProfilePic,
            badgeIconUrl: user?.badge?.completeIconUrl,
            themeColor: themeColor,
            width: 72.w,
            height: 88.h,
            avatarPaddingTop: 24.h,
            avatarSize: 60.sp,
          ),
          20.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "محتوى الدرس",
                  style: TextStyle(
                    color: const Color(0xFF10B981),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'SomarSans',
                  ),
                ),
                4.verticalSpace,
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'SomarSans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }
}

class _LessonAppBar extends ConsumerWidget {
  final String title;
  final double progress;
  final VoidCallback onClose;

  const _LessonAppBar({
    required this.title,
    required this.progress,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsNotifierProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 800;
        final double horizontalPadding = isDesktop ? 60.0 : 16.w;
        const double maxContentWidth = 1000.0;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A).withOpacity(0.9) : Colors.white.withOpacity(0.9),
            border: Border(
              bottom: BorderSide(
                color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : const Color(0xFFF1F5F9),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isDesktop ? 16.h : 8.h,
                ),
                child: Row(
                  children: [
                    // Theme Toggle Button
                    GestureDetector(
                      onTap: () => ref.read(settingsNotifierProvider.notifier).toggleDarkMode(),
                      child: Container(
                        width: 40.sp,
                        height: 40.sp,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          settings.isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                          size: 20.sp,
                          color: settings.isDarkMode ? Colors.yellow : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    
                    24.horizontalSpace,
                    
                    // Progress Bar Section
                    ExerciseHeader(progress: progress),
                    
                    20.horizontalSpace,
                    
                    // Close Button
                    IconButton(
                      onPressed: onClose,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: isDark ? Colors.white : const Color(0xFF64748B),
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LessonElementWidget extends HookWidget {
  final Map<String, dynamic> element;

  const _LessonElementWidget({required this.element});

  @override
  Widget build(BuildContext context) {
    final type = element['type'];
    final data = element['data'];

    switch (type) {
      case 'text':
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Center(
            child: Text(
              data['content'] ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                color: Colors.white.withOpacity(0.95),
                height: 1.6,
                fontWeight: FontWeight.w600,
                fontFamily: 'SomarSans',
              ),
            ),
          ),
        );
      case 'video':
        return _VideoElement(url: data['url'], filePath: data['file']);
      case 'audio':
        return _AudioElement(url: data['url'], filePath: data['file']);
      case 'flashcards':
        return _FlashcardsElement(cards: data['cards'] ?? []);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _VideoElement extends HookWidget {
  final String? url;
  final String? filePath;

  const _VideoElement({this.url, this.filePath});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: const Center(
          child: Icon(Icons.play_circle_outline, size: 64, color: Color(0xFF10B981)),
        ),
      ),
    );
  }
}

class _AudioElement extends HookWidget {
  final String? url;
  final String? filePath;

  const _AudioElement({this.url, this.filePath});

  @override
  Widget build(BuildContext context) {
    final player = useMemoized(() => AudioPlayer());
    final isPlaying = useState(false);

    useEffect(() {
      return player.dispose;
    }, []);

    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF10B981).withOpacity(0.2),
            child: const Icon(Icons.volume_up, color: Color(0xFF10B981)),
          ),
          SizedBox(width: 15.w),
          const Expanded(
            child: Text(
              'استمع للمقطع الصوتي',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            onPressed: () => isPlaying.value = !isPlaying.value,
            icon: Icon(isPlaying.value ? Icons.pause_circle_filled : Icons.play_circle_filled),
            color: Colors.white,
            iconSize: 32,
          ),
        ],
      ),
    );
  }
}

class _FlashcardsElement extends HookWidget {
  final List<dynamic> cards;

  const _FlashcardsElement({required this.cards});

  @override
  Widget build(BuildContext context) {
    final currentIndex = useState(0);
    final isFlipped = useState(false);

    if (cards.isEmpty) return const SizedBox.shrink();

    final currentCard = cards[currentIndex.value];

    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.h),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => isFlipped.value = !isFlipped.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 200.h,
              decoration: BoxDecoration(
                color: isFlipped.value ? const Color(0xFF064E3B) : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  isFlipped.value ? currentCard['back'] : currentCard['front'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: currentIndex.value > 0 ? () {
                  currentIndex.value--;
                  isFlipped.value = false;
                } : null,
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              Text(
                '${currentIndex.value + 1} / ${cards.length}',
                style: const TextStyle(color: Colors.white70),
              ),
              IconButton(
                onPressed: currentIndex.value < cards.length - 1 ? () {
                  currentIndex.value++;
                  isFlipped.value = false;
                } : null,
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
