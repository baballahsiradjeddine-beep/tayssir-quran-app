import 'dart:async';
import 'dart:math' as math;
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
import 'package:tayssir/features/exercice/presentation/view/select_right_option/latext_text_widget.dart';
import 'package:tayssir/router/app_router.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/features/exercice/presentation/state/exercice_controller.dart';
import 'package:tayssir/providers/data/data_provider.dart';
import 'package:tayssir/providers/user/user_notifier.dart';
import 'package:tayssir/common/core/shield_badge.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
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
                        : Center(child: Text('لا يوجد محتوى لهذا الدرس', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B)))),
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
        : (isDark ? AppColors.goldColor : AppColors.warmAccent);

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
                    color: isDark ? AppColors.goldColor : AppColors.warmAccent,
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
            child: LatextTextWidget(
              text: data['content'] ?? '',
              isLatex: (data['content'] ?? '').toString().contains('<') || (data['content'] ?? '').toString().contains('\\'),
              textStyle: TextStyle(
                fontSize: 20.sp,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.95) : const Color(0xFF1E293B),
                height: 1.6,
                fontWeight: FontWeight.w600,
                fontFamily: 'SomarSans',
              ),
              textAlign: TextAlign.center,
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

  String? _getYouTubeId(String url) {
    final regExp = RegExp(
      r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    return (match != null && match.group(7)?.length == 11) ? match.group(7) : null;
  }

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return const SizedBox.shrink();

    final youtubeId = _getYouTubeId(url!);
    if (youtubeId != null) {
      return _YouTubePlayer(videoId: youtubeId);
    }

    return _NormalVideoPlayer(url: url!);
  }
}

class _YouTubePlayer extends HookWidget {
  final String videoId;
  const _YouTubePlayer({required this.videoId});

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(() {
      return YoutubePlayerController.fromVideoId(
        videoId: videoId,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          mute: false,
          showVideoAnnotations: false,
        ),
      );
    }, [videoId]);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: YoutubePlayer(
        controller: controller,
        aspectRatio: 16 / 9,
      ),
    );
  }
}

class _NormalVideoPlayer extends HookWidget {
  final String url;
  const _NormalVideoPlayer({required this.url});

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(() {
      return VideoPlayerController.networkUrl(Uri.parse(url));
    }, [url]);

    final isInitialized = useState(false);
    final isPlaying = useState(false);
    final volume = useState(1.0);
    final playbackSpeed = useState(1.0);
    final hasError = useState(false);
    final showControls = useState(true);

    useEffect(() {
      controller.initialize().then((_) {
        isInitialized.value = true;
      }).catchError((e) => hasError.value = true);

      void listener() {
        isPlaying.value = controller.value.isPlaying;
        if (controller.value.hasError) hasError.value = true;
      }

      controller.addListener(listener);
      return () {
        controller.removeListener(listener);
        controller.dispose();
      };
    }, [controller]);

    void toggleFullScreen() {
      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (context, _, __) {
            return _FullScreenVideoPage(
              controller: controller,
              isPlaying: isPlaying,
              volume: volume,
              playbackSpeed: playbackSpeed,
            );
          },
        ),
      );
    }

    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 380.h),
          child: AspectRatio(
            aspectRatio: isInitialized.value ? controller.value.aspectRatio : 16 / 9,
            child: MouseRegion(
              onEnter: (_) => showControls.value = true,
              onExit: (_) => showControls.value = false,
              child: GestureDetector(
                onTap: () => showControls.value = !showControls.value,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.white10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isInitialized.value)
                        VideoPlayer(controller)
                      else if (hasError.value)
                        _buildErrorWidget()
                      else
                        CircularProgressIndicator(color: Theme.of(context).brightness == Brightness.dark ? AppColors.goldColor : AppColors.warmAccent),

                      // Controls Overlay
                      if (isInitialized.value && !hasError.value)
                        _VideoControls(
                          controller: controller,
                          isPlaying: isPlaying,
                          volume: volume,
                          playbackSpeed: playbackSpeed,
                          showControls: showControls,
                          onFullScreen: toggleFullScreen,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlsOverlay(
    BuildContext context,
    VideoPlayerController controller,
    ValueNotifier<bool> isPlaying,
    ValueNotifier<double> volume,
    ValueNotifier<double> playbackSpeed,
    ValueNotifier<bool> showControls, {
    bool isFullScreen = false,
    VoidCallback? onFullScreen,
  }) {
    return AnimatedOpacity(
      opacity: showControls.value ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Stack(
        children: [
          // Center Play/Pause
          Center(
            child: GestureDetector(
              onTap: () => isPlaying.value ? controller.pause() : controller.play(),
              child: Container(
                padding: EdgeInsets.all(isFullScreen ? 25.r : 15.r),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: isFullScreen ? 60.sp : 50.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          // Bottom Controls Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: Theme.of(context).brightness == Brightness.dark ? AppColors.goldColor : AppColors.warmAccent,
                      bufferedColor: Colors.white24,
                      backgroundColor: Colors.white10,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isPlaying.value ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: () => isPlaying.value ? controller.pause() : controller.play(),
                      ),
                      
                      // Volume Slider
                      const Icon(Icons.volume_up, color: Colors.white, size: 18),
                      SizedBox(
                        width: 80.w,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2,
                            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                            overlayShape: RoundSliderOverlayShape(overlayRadius: 10),
                          ),
                          child: Slider(
                            value: volume.value,
                            activeColor: Theme.of(context).brightness == Brightness.dark ? AppColors.goldColor : AppColors.warmAccent,
                            inactiveColor: Colors.white24,
                            onChanged: (val) {
                              volume.value = val;
                              controller.setVolume(val);
                            },
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Speed Toggle
                      TextButton(
                        onPressed: () {
                          final speeds = [0.5, 1.0, 1.5, 2.0];
                          final nextIndex = (speeds.indexOf(playbackSpeed.value) + 1) % speeds.length;
                          playbackSpeed.value = speeds[nextIndex];
                          controller.setPlaybackSpeed(playbackSpeed.value);
                        },
                        child: Text(
                          '${playbackSpeed.value}x',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      
                      if (onFullScreen != null)
                        IconButton(
                          icon: const Icon(Icons.fullscreen, color: Colors.white),
                          onPressed: onFullScreen,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.redAccent, size: 40.sp),
          8.verticalSpace,
          const Text('تعذر تشغيل الفيديو', style: TextStyle(color: Colors.white70)),
        ],
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
    final isLoaded = useState(false);

    useEffect(() {
      if (url != null && url!.isNotEmpty) {
        player.setUrl(url!).then((_) {
          isLoaded.value = true;
        });
      }
      
      final subscription = player.playerStateStream.listen((state) {
        isPlaying.value = state.playing;
      });
      
      return () {
        subscription.cancel();
        player.dispose();
      };
    }, [url]);

    if (url == null || url!.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPlaying.value ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
              color: const Color(0xFF10B981),
              size: 20.sp,
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'استمع للمقطع الصوتي',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B),
                    fontWeight: FontWeight.w900,
                    fontSize: 14.sp,
                    fontFamily: 'SomarSans',
                  ),
                ),
                if (!isLoaded.value)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      'جاري التحميل...',
                      style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54, fontSize: 10.sp),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: isLoaded.value ? () {
              if (isPlaying.value) {
                player.pause();
              } else {
                player.play();
              }
            } : null,
            icon: Icon(
              isPlaying.value 
                  ? Icons.pause_circle_filled_rounded 
                  : Icons.play_circle_filled_rounded,
            ),
            color: isLoaded.value ? const Color(0xFF10B981) : Colors.white24,
            iconSize: 42.sp,
          ),
        ],
      ),
    );
  }
}

class _FlashcardsElement extends StatelessWidget {
  final List<dynamic> cards;

  const _FlashcardsElement({required this.cards});

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        children: cards.map((card) => _IndividualFlipCard(
          front: card['front'] ?? '',
          back: card['back'] ?? '',
        )).toList(),
      ),
    );
  }
}

class _IndividualFlipCard extends HookWidget {
  final String front;
  final String back;

  const _IndividualFlipCard({required this.front, required this.back});

  @override
  Widget build(BuildContext context) {
    final isFlipped = useState(false);
    final flipController = useAnimationController(duration: const Duration(milliseconds: 500));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color emeraldColor = AppColors.emerald700;
    final Color goldColor = const Color(0xFFD97706);

    return GestureDetector(
      onTap: () {
        if (isFlipped.value) {
          flipController.reverse();
        } else {
          flipController.forward();
        }
        isFlipped.value = !isFlipped.value;
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: AnimatedBuilder(
          animation: flipController,
          builder: (context, child) {
            final angle = flipController.value * math.pi;
            final isFront = angle <= math.pi / 2;

            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateX(angle),
              alignment: Alignment.center,
              child: isFront
                  ? _buildFace(context, front, true, isDark, emeraldColor)
                  : Transform(
                      transform: Matrix4.identity()..rotateX(math.pi),
                      alignment: Alignment.center,
                      child: _buildFace(context, back, false, isDark, goldColor),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFace(BuildContext context, String text, bool isFront, bool isDark, Color accentColor) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 120.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? accentColor.withOpacity(0.2) : accentColor.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          children: [
            // Side Indicator
            Positioned(
              left: 0, top: 0, bottom: 0,
              width: 5.w,
              child: Container(color: accentColor),
            ),
            
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          isFront ? 'المفهوم' : 'الشرح',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                            fontFamily: 'SomarSans',
                          ),
                        ),
                      ),
                      Icon(
                        isFront ? Icons.help_outline_rounded : Icons.info_outline_rounded,
                        size: 16.sp,
                        color: accentColor.withOpacity(0.5),
                      ),
                    ],
                  ),
                  12.verticalSpace,
                  Center(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.emerald900,
                        fontFamily: 'SomarSans',
                        height: 1.4,
                      ),
                    ),
                  ),
                  8.verticalSpace,
                  Center(
                    child: Opacity(
                      opacity: 0.4,
                      child: Text(
                        isFront ? 'اضغط لرؤية التوضيح ↺' : 'اضغط للعودة ↺',
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontFamily: 'SomarSans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenVideoPage extends StatelessWidget {
  final VideoPlayerController controller;
  final ValueNotifier<bool> isPlaying;
  final ValueNotifier<double> volume;
  final ValueNotifier<double> playbackSpeed;

  const _FullScreenVideoPage({
    required this.controller,
    required this.isPlaying,
    required this.volume,
    required this.playbackSpeed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
          Positioned(
            top: 40.h,
            right: 20.w,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 30.h,
            left: 0,
            right: 0,
            child: _VideoControls(
              controller: controller,
              isPlaying: isPlaying,
              volume: volume,
              playbackSpeed: playbackSpeed,
              showControls: ValueNotifier(true),
              isFullScreen: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoControls extends HookWidget {
  final VideoPlayerController controller;
  final ValueNotifier<bool> isPlaying;
  final ValueNotifier<double> volume;
  final ValueNotifier<double> playbackSpeed;
  final ValueNotifier<bool> showControls;
  final bool isFullScreen;
  final VoidCallback? onFullScreen;

  const _VideoControls({
    required this.controller,
    required this.isPlaying,
    required this.volume,
    required this.playbackSpeed,
    required this.showControls,
    this.isFullScreen = false,
    this.onFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: showControls.value ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Stack(
        children: [
          // Center Play/Pause
          if (showControls.value)
            Center(
              child: GestureDetector(
                onTap: () => isPlaying.value ? controller.pause() : controller.play(),
                child: Container(
                  padding: EdgeInsets.all(isFullScreen ? 25.r : 15.r),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: isFullScreen ? 60.sp : 50.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          
          // Bottom Controls Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: const Color(0xFF10B981),
                      bufferedColor: Colors.white24,
                      backgroundColor: Colors.white10,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isPlaying.value ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: () => isPlaying.value ? controller.pause() : controller.play(),
                      ),
                      
                      // Volume Slider
                      const Icon(Icons.volume_up, color: Colors.white, size: 18),
                      SizedBox(
                        width: isFullScreen ? 120.w : 80.w,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2,
                            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                            overlayShape: RoundSliderOverlayShape(overlayRadius: 10),
                          ),
                          child: Slider(
                            value: volume.value,
                            activeColor: const Color(0xFF10B981),
                            inactiveColor: Colors.white24,
                            onChanged: (val) {
                              volume.value = val;
                              controller.setVolume(val);
                            },
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Speed Toggle
                      TextButton(
                        onPressed: () {
                          final speeds = [0.5, 1.0, 1.5, 2.0];
                          final nextIndex = (speeds.indexOf(playbackSpeed.value) + 1) % speeds.length;
                          playbackSpeed.value = speeds[nextIndex];
                          controller.setPlaybackSpeed(playbackSpeed.value);
                        },
                        child: Text(
                          '${playbackSpeed.value}x',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      
                      if (onFullScreen != null)
                        IconButton(
                          icon: const Icon(Icons.fullscreen, color: Colors.white),
                          onPressed: onFullScreen,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
