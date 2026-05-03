import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:tayssir/features/onboarding/onboarding_notifier.dart';
import 'package:tayssir/router/app_router.dart';
import 'package:tayssir/services/sounds/sound_manager.dart';
import 'package:tayssir/providers/special_effect/special_effect_provider.dart';
import 'package:flutter/services.dart';
import 'package:tayssir/features/ai_planner/presentation/ai_planner_fab.dart';
import 'package:tayssir/providers/auth/auth_notifier.dart';
import 'package:tayssir/providers/data/data_provider.dart';
import 'package:tayssir/utils/enums/auth_state.dart';

// ── Global showcase keys for each nav tab ──
final GlobalKey tourKeyHome = GlobalKey();
final GlobalKey tourKeyLeaderboard = GlobalKey();
final GlobalKey tourKeyTools = GlobalKey();
final GlobalKey tourKeyChallenges = GlobalKey();
final GlobalKey tourKeySettings = GlobalKey();
final GlobalKey tourKeyFirstMaterial = GlobalKey();

/// The ordered list of showcase keys + which tab they belong to
const _tourOrder = [
  // (navIndex, label, description)
  _TourStepDef(
    navIndex: 2,
    label: 'الصفحة الرئيسية 📖',
    desc: 'مرحباً بك! هنا تجد كل أورادك وسورك منظمة حسب روايتك.',
  ),
  _TourStepDef(
    navIndex: 1,
    label: 'لوحة المتصدرين 🏆',
    desc: 'هنا يمكنك منافسة زملائك ورؤية ترتيبك في حفظ كتاب الله!',
  ),
  _TourStepDef(
    navIndex: 3,
    label: 'صفحة التحديات 🎮',
    desc: 'تحدى نفسك وأصدقاءك في مراجعة الآيات وتثبيتها بطرق ممتعة.',
  ),
  _TourStepDef(
    navIndex: 0,
    label: 'صفحة الأدوات 🧰',
    desc: 'هنا تجد كل ما يساعدك: بومودورو التركيز، وتتبع التقدم في الحفظ.',
  ),
  _TourStepDef(
    navIndex: 4,
    label: 'الإعدادات ⚙️',
    desc: 'خصص حسابك، اختر الوضع الليلي، وتحكم في تنبيهاتك بكل سهولة.',
  ),
];

class _TourStepDef {
  final int navIndex;
  final String label;
  final String desc;
  const _TourStepDef({
    required this.navIndex,
    required this.label,
    required this.desc,
  });
}

GlobalKey _keyForStep(int stepIndex) {
  if (stepIndex >= _tourOrder.length) return tourKeyFirstMaterial;
  switch (_tourOrder[stepIndex].navIndex) {
    case 0: return tourKeyTools;
    case 1: return tourKeyLeaderboard;
    case 2: return tourKeyHome;
    case 3: return tourKeyChallenges;
    case 4: return tourKeySettings;
    default: return tourKeyHome;
  }
}

class MainScaffold extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  const MainScaffold({super.key, required this.navigationShell});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  BuildContext? _showCaseContext;
  bool _tourStarted = false;
  bool _registerSheetShown = false;

  void _startTourIfNeeded(BuildContext showCaseCtx) {
    if (_tourStarted) return;
    final tourStep = ref.read(onboardingProvider).tourStep;
    if (tourStep < 0 || tourStep >= 6) return;

    _tourStarted = true;
    _showCaseContext = showCaseCtx;

    // Map tourStep → showcase key
    final stepIndex = tourStep < _tourOrder.length ? tourStep : 0;
    final key = _keyForStep(stepIndex);

    // Delay so screen renders fully and layout stabilizes first
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        // Wait for potential animations and layout settling
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted) {
          ShowCaseWidget.of(showCaseCtx).startShowCase([key]);
        }
      }
    });
  }

  // Called when user taps the highlighted nav item (showcase bubble dismissed).
  // showcaseview intercepts taps and never fires the widget's own onTap,
  // so we handle navigation + tour advancement here.
  void _onShowCaseComplete(int? showcaseIndex, GlobalKey key) async {
    final current = ref.read(onboardingProvider).tourStep;
    if (current < 0 || current >= _tourOrder.length) return;

    final isSoundOn = ref.read(isSoundEnabledProvider);
    if (isSoundOn) SoundService.playClickPremium();
    HapticFeedback.lightImpact();

    // 1. Navigate to the tapped tab right away
    final navIndex = _tourOrder[current].navIndex;
    widget.navigationShell.goBranch(
      navIndex,
      initialLocation: true,
    );

    final next = current + 1;

    if (next >= _tourOrder.length) {
      // Nav tour done — Go back to Home for Material spotlight
      await ref.read(onboardingProvider.notifier).setTourStep(5); // step 5 = Home material spotlight
      widget.navigationShell.goBranch(2, initialLocation: true);
      setState(() => _tourStarted = false);
    } else {
      // Advance state and start next showcase
      await ref.read(onboardingProvider.notifier).setTourStep(next);
      setState(() => _tourStarted = false);

      if (_showCaseContext != null && mounted) {
        final nextKey = _keyForStep(next);
        // Wait for the new tab's page to render before highlighting
        await Future.delayed(const Duration(milliseconds: 700));
        if (mounted) {
          ShowCaseWidget.of(_showCaseContext!).startShowCase([nextKey]);
        }
      }
    }
  }

  // onFinish fires after the whole batch completes — not used since we
  // handle everything in onComplete.
  void _onShowCaseDone() {}

  void _showRegisterSheet() {
    final name = ref.read(onboardingProvider).name ?? 'صديقي';
    final isDesktop = MediaQuery.sizeOf(context).width > 800;

    if (isDesktop) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: Material(
              color: Colors.transparent,
              child: _RegisterNowSheet(
                name: name,
                onRegister: () async {
                  await ref.read(onboardingProvider.notifier).completeOnboarding();
                  if (mounted) {
                    Navigator.pop(context);
                    context.goNamed(AppRoutes.register.name);
                  }
                },
                onSkip: () async {
                  await ref.read(onboardingProvider.notifier).completeOnboarding();
                  if (mounted) Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (_) => _RegisterNowSheet(
          name: name,
          onRegister: () async {
            await ref.read(onboardingProvider.notifier).completeOnboarding();
            if (mounted) {
              Navigator.pop(context);
              context.goNamed(AppRoutes.register.name);
            }
          },
          onSkip: () async {
            await ref.read(onboardingProvider.notifier).completeOnboarding();
            if (mounted) Navigator.pop(context);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tourStep = ref.watch(onboardingProvider).tourStep;
    // Trigger Register Sheet after tour completion
    final authStatus = ref.watch(authNotifierProvider).status;
    final isGuest = authStatus == AuthStatus.unauthenticated || authStatus == AuthStatus.unknown;

    // Trigger Register Sheet after tour completion
    // We only trigger if navigation is on the home tab (index 2) to avoid showing it over other screens
    final isHomeTab = widget.navigationShell.currentIndex == 2;

    if (tourStep == 99 && isGuest && !_registerSheetShown && isHomeTab) {
      _registerSheetShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Silently ensure mock data is present and RE-ADD it if it was cleared
        ref.read(dataProvider.notifier).ensureMockData(force: true);
        
        // Delay to ensure the Home screen is fully visible and transition is done
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted && widget.navigationShell.currentIndex == 2) {
            _showRegisterSheet();
          } else {
            // If the user navigated away before the delay, allow it to trigger again later
            _registerSheetShown = false;
          }
        });
      });
    }

    final isTourActive = tourStep >= 0 && tourStep <= 5; // step 5 is the material highlight in HomeScreen

    final currentStepDef = (tourStep >= 0 && tourStep < _tourOrder.length) 
        ? _tourOrder[tourStep] 
        : null;

    return ShowCaseWidget(
      onFinish: _onShowCaseDone,
      onComplete: _onShowCaseComplete,
      builder: (showCaseCtx) {
        // Trigger tour on first build if active
        if (isTourActive && !_tourStarted) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _startTourIfNeeded(showCaseCtx),
          );
        }
        
        final isDesktop = MediaQuery.sizeOf(context).width > 800;

        return Scaffold(
          extendBody: !isDesktop,
          backgroundColor: isDesktop ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)) : null,
          body: Stack(
            children: [
              if (isDesktop)
                Row(
                  textDirection: TextDirection.rtl, // Sidebar on the RIGHT (Original)
                  children: [
                    _DesktopSidebar(
                      currentIndex: widget.navigationShell.currentIndex,
                      isTourActive: isTourActive,
                      currentTourNavIndex: (tourStep >= 0 && tourStep < _tourOrder.length)
                          ? _tourOrder[tourStep].navIndex
                          : -1,
                      onTap: (index) => widget.navigationShell.goBranch(index, initialLocation: widget.navigationShell.currentIndex == index),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          widget.navigationShell,
                          // Study Plan Button (On the LEFT for both mobile and desktop)
                          if (widget.navigationShell.currentIndex == 2)
                            const AIPlannerFAB(),
                        ],
                      ),
                    ),
                  ],
                )
              else
                widget.navigationShell,
                
              if (isTourActive && tourStep < _tourOrder.length)
                _RefiqBubbleOverlay(
                  step: currentStepDef,
                  name: ref.read(onboardingProvider).name ?? 'صديقي',
                ),
            ],
          ),
          bottomNavigationBar: isDesktop ? null : _TourAwareNavBar(
            currentIndex: widget.navigationShell.currentIndex,
            isTourActive: isTourActive,
            currentTourNavIndex: (tourStep >= 0 && tourStep < _tourOrder.length)
                ? _tourOrder[tourStep].navIndex
                : -1,
            onTap: (index) {
              widget.navigationShell.goBranch(index,
                  initialLocation: widget.navigationShell.currentIndex == index);
            },
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────
// Tour-aware Bottom Nav Bar
// ─────────────────────────────────────────

GlobalKey keyForNavIndex(int index) {
  switch (index) {
    case 0: return tourKeyTools;
    case 1: return tourKeyLeaderboard;
    case 2: return tourKeyHome;
    case 3: return tourKeyChallenges;
    case 4: return tourKeySettings;
    default: return tourKeyHome;
  }
}

class _TourAwareNavBar extends ConsumerWidget {
  final int currentIndex;
  final bool isTourActive;
  final int currentTourNavIndex;
  final Function(int) onTap;

  const _TourAwareNavBar({
    required this.currentIndex,
    required this.isTourActive,
    required this.currentTourNavIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 80.h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Background
          _NavBackground(isDark: isDark),

          // Items
          Container(
            height: 80.h,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildNavItem(context, ref, 0, Icons.category_outlined, Icons.category_rounded, "أدوات", isDark),
                _buildNavItem(context, ref, 1, Icons.leaderboard_outlined, Icons.leaderboard_rounded, "ترتيب", isDark),
                _buildNavItem(context, ref, 2, Icons.home_outlined, Icons.home_rounded, "الرئيسية", isDark),
                _buildNavItem(context, ref, 3, Icons.flag_outlined, Icons.flag_rounded, "تحديات", isDark),
                _buildNavItem(context, ref, 4, Icons.settings_outlined, Icons.settings_rounded, "اعدادات", isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    WidgetRef ref,
    int index,
    IconData outlineIcon,
    IconData filledIcon,
    String label,
    bool isDark,
  ) {
    final isSelected = currentIndex == index;
    final isTargetted = isTourActive && index == currentTourNavIndex;
    final isBlocked = isTourActive && index != currentTourNavIndex;
    final isSoundOn = ref.watch(isSoundEnabledProvider);
    
    final VoidCallback? tapCallback = isBlocked ? null : () {
      if (isSoundOn && !isSelected) {
        SoundService.playClickPremium();
        HapticFeedback.lightImpact();
      }
      onTap(index);
    };

    // For selected item: build the floating container using layout padding 
    // instead of Transform.translate so Showcase calculates the exact bounds.
    if (isSelected) {
      Widget showcasedOrNot = GestureDetector(
        onTap: tapCallback,
        child: Container(
          width: 68.sp,
          height: 68.sp,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(filledIcon, size: 30.sp, color: Colors.white),
        ),
      ).animate().scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);

      if (isTargetted) {
        final step = _tourOrder.firstWhere((s) => s.navIndex == index,
            orElse: () => const _TourStepDef(navIndex: -1, label: '', desc: ''));
        showcasedOrNot = Showcase(
          key: keyForNavIndex(index),
          description: '',
          showArrow: false,
          tooltipBackgroundColor: Colors.transparent,
          tooltipPosition: TooltipPosition.top,
          targetBorderRadius: BorderRadius.circular(24.r),
          overlayOpacity: 0.3,
          targetPadding: EdgeInsets.all(8.sp),
          child: showcasedOrNot,
        );
      }

      // Use Padding to push the element up in the layout tree, 
      // preventing any Showcase bounding box calculation errors.
      return Padding(
        padding: EdgeInsets.only(bottom: 25.h),
        child: showcasedOrNot,
      );
    }

    // Non-selected item
    Widget item = _NavItemWidget(
      index: index,
      outlineIcon: outlineIcon,
      filledIcon: filledIcon,
      label: label,
      isDark: isDark,
      isSelected: false,
      onTap: tapCallback,
    );

    if (isTargetted) {
      final step = _tourOrder.firstWhere((s) => s.navIndex == index,
          orElse: () => const _TourStepDef(navIndex: -1, label: '', desc: ''));
      item = Showcase(
        key: keyForNavIndex(index),
        description: '',
        showArrow: false,
        tooltipBackgroundColor: Colors.transparent,
        tooltipPosition: TooltipPosition.top,
        targetBorderRadius: BorderRadius.circular(16.r),
        overlayOpacity: 0.3,
        targetPadding: EdgeInsets.all(8.sp),
        child: item,
      );
    }

    return item;
  }
}

class _NavItemWidget extends StatelessWidget {
  final int index;
  final IconData outlineIcon;
  final IconData filledIcon;
  final String label;
  final bool isDark;
  final bool isSelected;
  final VoidCallback? onTap;

  const _NavItemWidget({
    required this.index,
    required this.outlineIcon,
    required this.filledIcon,
    required this.label,
    required this.isDark,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Note: selected state is now handled in _buildNavItem directly
    // to allow Showcase to wrap the visual position correctly.
    if (isSelected) {
      return GestureDetector(
        onTap: onTap,
        child: Transform.translate(
          offset: Offset(0, -25.h),
          child: Container(
            width: 68.sp,
            height: 68.sp,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(filledIcon, size: 30.sp, color: Colors.white),
          ),
        ),
      ).animate().scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 60.w,
        padding: EdgeInsets.only(bottom: 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              outlineIcon,
              size: 26.sp,
              color: onTap == null
                  ? (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E0))
                  : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
            ),
            6.verticalSpace,
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: onTap == null
                    ? (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E0))
                    : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                fontFamily: 'SomarSans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Tito bubble overlay during tour
// ─────────────────────────────────────────

class _RefiqBubbleOverlay extends StatelessWidget {
  final _TourStepDef? step;
  final String name;

  const _RefiqBubbleOverlay({this.step, required this.name});

  @override
  Widget build(BuildContext context) {
    if (step == null) return const SizedBox.shrink();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 20.h,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500.w),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.98),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.8), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      step!.desc,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'SomarSans',
                        height: 1.4,
                      ),
                    ),
                  ),
                  16.horizontalSpace,
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Text('📖', style: TextStyle(fontSize: 28.sp)),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.5, end: 0, curve: Curves.easeOutBack),
          ),
        ),
      ),
    );
  }
}

// ── Nav Background helper ──
class _NavBackground extends StatelessWidget {
  final bool isDark;
  const _NavBackground({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(32.r),
        topRight: Radius.circular(32.r),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 80.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0F172A).withOpacity(0.85)
                : Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32.r),
              topRight: Radius.circular(32.r),
            ),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Register Now Bottom Sheet
// ─────────────────────────────────────────

class _RegisterNowSheet extends StatelessWidget {
  final String name;
  final VoidCallback onRegister;
  final VoidCallback onSkip;

  const _RegisterNowSheet({
    required this.name,
    required this.onRegister,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 500.w),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.15),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🎉📖', style: TextStyle(fontSize: 50.sp))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: -6, end: 6, duration: 2.seconds),
            16.verticalSpace,
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'أحسنت يا '),
                  TextSpan(
                    text: name,
                    style: const TextStyle(color: Color(0xFF10B981)),
                  ),
                  const TextSpan(text: ' ! 🌟'),
                ],
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.w900,
                fontFamily: 'SomarSans',
              ),
            ),
            10.verticalSpace,
            Text(
              'رأيت كل ما يقدمه التطبيق!\nسجّل الآن لتحفظ مسارك ونقاطك',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: const Color(0xFF94A3B8),
                fontSize: 15.sp,
                fontFamily: 'SomarSans',
                height: 1.5,
              ),
            ),
            24.verticalSpace,
            GestureDetector(
              onTap: onRegister,
              child: Container(
                width: double.infinity,
                height: 54.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(18.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    '🔑 إنشاء حساب مجاناً',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'SomarSans',
                    ),
                  ),
                ),
              ),
            ),
            16.verticalSpace,
            GestureDetector(
              onTap: onSkip,
              child: Text(
                'تخطي الآن',
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: 14.sp,
                  fontFamily: 'SomarSans',
                  decoration: TextDecoration.underline,
                  decorationColor: const Color(0xFF64748B),
                ),
              ),
            ),
            8.verticalSpace,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Desktop Side Bar
// ─────────────────────────────────────────

class _DesktopSidebar extends ConsumerWidget {
  final int currentIndex;
  final bool isTourActive;
  final int currentTourNavIndex;
  final Function(int) onTap;

  const _DesktopSidebar({
    required this.currentIndex,
    required this.isTourActive,
    required this.currentTourNavIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final isSoundOn = ref.watch(isSoundEnabledProvider);

    return Container(
      width: 250.w,
      height: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          left: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo or Title
          Center(
            child: Text(
              'بيان القرآن',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF10B981),
                fontFamily: 'SomarSans',
                letterSpacing: 1.2,
              ),
            ),
          ),
          60.verticalSpace,
          _buildSidebarItem(context, isSoundOn, 2, Icons.home_outlined, Icons.home_rounded, "الرئيسية"),
          20.verticalSpace,
          _buildSidebarItem(context, isSoundOn, 1, Icons.leaderboard_outlined, Icons.leaderboard_rounded, "ترتيب"),
          20.verticalSpace,
          _buildSidebarItem(context, isSoundOn, 3, Icons.flag_outlined, Icons.flag_rounded, "تحديات"),
          20.verticalSpace,
          _buildSidebarItem(context, isSoundOn, 0, Icons.category_outlined, Icons.category_rounded, "أدوات"),
          if (!isTourActive) ...[
            20.verticalSpace,
            _buildSpecialSidebarItem(
              context, 
              isSoundOn, 
              Icons.card_membership_rounded, 
              "تفعيل الحساب", 
              () => context.pushNamed(AppRoutes.subscriptionOptions.name)
            ),
          ],
          const Spacer(),
          _buildSidebarItem(context, isSoundOn, 4, Icons.settings_outlined, Icons.settings_rounded, "اعدادات"),
        ],
      ),
    );
  }

  Widget _buildSpecialSidebarItem(BuildContext context, bool isSoundOn, IconData icon, String label, VoidCallback onTap) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const premiumPink = Color(0xFFF59E0B);
    
    return GestureDetector(
      onTap: () {
        if (isSoundOn) {
          SoundService.playClickPremium();
          HapticFeedback.lightImpact();
        }
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              premiumPink.withOpacity(0.15),
              premiumPink.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: premiumPink.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              size: 24.sp,
              color: premiumPink,
            ),
            16.horizontalSpace,
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: premiumPink,
                  fontFamily: 'SomarSans',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, bool isSoundOn, int index, IconData outlineIcon, IconData filledIcon, String label) {
    final isSelected = currentIndex == index;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final isTargetted = isTourActive && index == currentTourNavIndex;
    final isBlocked = isTourActive && index != currentTourNavIndex;

    Widget item = GestureDetector(
      onTap: isBlocked ? null : () {
        if (!isSelected && isSoundOn) {
          SoundService.playClickPremium();
          HapticFeedback.lightImpact();
        }
        onTap(index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981).withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981).withOpacity(0.5) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? filledIcon : outlineIcon,
              size: 28.sp,
              color: isSelected ? const Color(0xFF10B981) : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
            20.horizontalSpace,
            Text(
              label,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected ? const Color(0xFF10B981) : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569)),
                fontFamily: 'SomarSans',
              ),
            ),
          ],
        ),
      ),
    );

    if (isTargetted) {
      final step = _tourOrder.firstWhere((s) => s.navIndex == index,
          orElse: () => const _TourStepDef(navIndex: -1, label: '', desc: ''));
          
      return Showcase(
        key: keyForNavIndex(index),
        description: '',
        showArrow: false,
        tooltipBackgroundColor: Colors.transparent,
        tooltipPosition: TooltipPosition.bottom,
        targetBorderRadius: BorderRadius.circular(16.r),
        overlayOpacity: 0.3,
        targetPadding: EdgeInsets.all(8.sp),
        child: item,
      );
    }

    return item;
  }
}
