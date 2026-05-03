import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/common/bayan_bubble_talk_widget.dart';
import 'package:tayssir/features/tools/pomodoro/state/pomodor_status_x.dart';
import 'package:tayssir/features/tools/pomodoro/state/pomodoro_controller.dart';
import 'package:tayssir/features/tools/pomodoro/state/pomodoro_state.dart';
import 'package:tayssir/features/tools/pomodoro/state/pomodoro_status.dart';
import 'package:tayssir/services/actions/dialog_service.dart';
import 'package:tayssir/services/sounds/sound_manager.dart';
import 'package:tayssir/providers/special_effect/special_effect_provider.dart';
import 'package:tayssir/common/core/app_assets/dynamic_app_asset.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:tayssir/utils/enums/triangle_side.dart';

class PomodoroScreen extends HookConsumerWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<PomodoroState>(pomodoroControllerProvider, (prev, next) {
      if (next.status == PomodoroStatus.stopped && prev?.status != PomodoroStatus.stopped) {
        DialogService.showPomodoroDoneDialog(context, () {
          ref.read(pomodoroControllerProvider.notifier).reset();
        });
      }
    });

    final state = ref.watch(pomodoroControllerProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    String getTime() {
      final minutes = (state.remainingTime ~/ 60).toString().padLeft(2, '0');
      final seconds = (state.remainingTime % 60).toString().padLeft(2, '0');
      return "$minutes:$seconds";
    }

    return AppScaffold(
      includeBackButton: false,
      topSafeArea: true,
      paddingX: 0,
      paddingB: 0,
      maxWidth: 1000,
      bodyBackgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(110.h),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: SizedBox(
              width: double.infinity,
              child: Container(
                padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title Area (Right Side in RTL)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'مؤقت الحفظ 📖',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                            fontFamily: 'SomarSans',
                          ),
                        ),
                      ],
                    ),
                    // Navigation Area (Left Side in RTL)
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18.sp,
                          color: isDark ? Colors.white : AppColors.primaryColor,
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    20.verticalSpace,

                    // Tito Advice Bubble
                    Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 240.w),
                        child: BayanBubbleTalkWidget(
                          text: state.status.adviceText,
                          triangleSide: TriangleSide.bottom,
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms).scale(curve: Curves.easeOutBack, duration: 600.ms),

                    20.verticalSpace,

                    // Circular Timer and Mascot
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Circular Progress
                          SizedBox(
                            width: 210.r,
                            height: 210.r,
                            child: CustomPaint(
                              painter: PomodoroCirclePainter(
                                progress: state.progress,
                                isDark: isDark,
                              ),
                            ),
                          ),

                          // Tito Character (Premium SVG)
                          DynamicAppAsset(
                            assetKey: state.status.statusAssetKey,
                            fallbackAssetPath: state.status.statusSvg,
                            type: AppAssetType.svg,
                            height: 120.h,
                          ).animate(target: state.isRunning ? 1 : 0)
                              .moveY(begin: 0, end: -5, duration: 2.seconds, curve: Curves.easeInOutSine)
                              .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2.seconds, curve: Curves.easeInOutSine),

                          // Alarm Overlay (Status specific)
                          if (state.isRunning)
                            Positioned(
                              bottom: 45.h,
                              right: 30.w,
                              child: Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.9),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Icon(Icons.timer_outlined, color: Colors.white, size: 24.sp),
                              ).animate(onPlay: (c) => c.repeat())
                                  .shimmer(duration: 2.seconds)
                                  .scale(duration: 1.seconds),
                            ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                    32.verticalSpace,

                    // Digital Time
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        getTime(),
                        style: TextStyle(
                          fontSize: 42.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF10B981),
                          fontFamily: 'SomarSans',
                          letterSpacing: 2,
                        ),
                      ),
                    ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack),

                    30.verticalSpace,
                    
                    // Action Buttons Row
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Main Action Button (Start/Pause)
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 400.w),
                            child: SizedBox(
                              width: double.infinity,
                              child: GestureDetector(
                                onTap: () {
                                  final isSoundOn = ref.read(isSoundEnabledProvider);
                                  if (isSoundOn) SoundService.playClickPremium();
                                  
                                  if (state.isRunning) {
                                    ref.read(pomodoroControllerProvider.notifier).pause();
                                  } else {
                                    ref.read(pomodoroControllerProvider.notifier).start();
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  decoration: BoxDecoration(
                                    gradient: state.isRunning
                                        ? null
                                        : const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                                    color: state.isRunning
                                        ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))
                                        : null,
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: state.isRunning ? Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)) : null,
                                    boxShadow: state.isRunning ? [] : [
                                      BoxShadow(
                                        color: const Color(0xFF10B981).withOpacity(0.15),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      )
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      state.isRunning ? "إيقاف" : (state.remainingTime < state.totalTime ? "أكمل" : "إبدأ"),
                                      style: TextStyle(
                                        color: state.isRunning ? (isDark ? Colors.white : const Color(0xFF1E293B)) : Colors.white,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'SomarSans',
                                      ),
                                    ),
                                  ),
                                ),
                              ).animate(target: state.isRunning ? 0 : 1)
                                  .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1), duration: 200.ms),
                            ),
                          ),
                          
                          // Reset Button (Conditional and in the same row)
                          if (state.canReset) ...[
                            12.horizontalSpace,
                            GestureDetector(
                              onTap: () => ref.read(pomodoroControllerProvider.notifier).reset(),
                              child: Container(
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                                  ]
                                ),
                                child: Icon(Icons.refresh_rounded, color: const Color(0xFF10B981), size: 24.sp),
                              ),
                            ).animate().fadeIn(delay: 800.ms).scale(curve: Curves.easeOutBack),
                          ],
                        ],
                      ),
                    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),

                    40.verticalSpace,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PomodoroCirclePainter extends CustomPainter {
  final double progress;
  final bool isDark;

  PomodoroCirclePainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;
    
    // Background Circle
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress Arc
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF059669)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // In HTML, it goes clockwise. 0% is top (-90 degrees).
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );

    // Knob (Indicator Circle)
    final knobOffset = Offset(
      center.dx + radius * math.cos(-math.pi / 2 + 2 * math.pi * progress),
      center.dy + radius * math.sin(-math.pi / 2 + 2 * math.pi * progress),
    );

    final knobPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final knobBorderPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(knobOffset, 11, knobPaint);
    canvas.drawCircle(knobOffset, 11, knobBorderPaint);
    
    // Glow for knob
    final glowPaint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(knobOffset, 11, glowPaint);
  }

  @override
  bool shouldRepaint(covariant PomodoroCirclePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
