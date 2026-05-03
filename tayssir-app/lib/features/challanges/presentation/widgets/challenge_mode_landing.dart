import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/core/app_assets/dynamic_app_asset.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:tayssir/resources/resources.dart';
import 'package:tayssir/router/app_router.dart';
import 'package:tayssir/services/sounds/sound_manager.dart';
import 'package:tayssir/providers/data/data_provider.dart';
import 'package:tayssir/providers/special_effect/special_effect_provider.dart';

class ChallengeModeLanding extends ConsumerStatefulWidget {
  final VoidCallback onEnterMode;
  const ChallengeModeLanding({super.key, required this.onEnterMode});

  @override
  ConsumerState<ChallengeModeLanding> createState() => _ChallengeModeLandingState();
}

class _ChallengeModeLandingState extends ConsumerState<ChallengeModeLanding> {
  bool _pressing = false;

  void _onTapDown(TapDownDetails details) => setState(() => _pressing = true);
  void _onTapUp(TapUpDetails details) => setState(() => _pressing = false);
  void _onTapCancel() => setState(() => _pressing = false);

  void _handleEnter() {
    final isSoundOn = ref.read(isSoundEnabledProvider);
    if (isSoundOn) SoundService.playAction();
    HapticFeedback.mediumImpact();
    _showPortalOverlay(context, () {
      widget.onEnterMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkColor : AppColors.scaffoldColor,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final double availableWidth = constraints.maxWidth;
            final bool isDesktop = availableWidth > 800;
            final double horizontalPadding = isDesktop ? 60.0 : 0.0;

            return Stack(
              children: [
                // ── Background gradient ──
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [
                                AppColors.secondaryDark,
                                AppColors.darkColor,
                                const Color(0xFF060914),
                              ]
                            : [
                                const Color(0xFFECFDF5),
                                const Color(0xFFF9FAFB),
                              ],
                      ),
                    ),
                  ),
                ),

                // ── Blob top-left ──
                Positioned(
                  top: -80.h,
                  left: -80.w,
                  child: Container(
                    width: 260.w,
                    height: 260.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor.withOpacity(0.08),
                    ),
                  ),
                ),
                Positioned(
                  top: 40.h,
                  left: -30.w,
                  child: Container(
                    width: 90.w,
                    height: 90.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold600.withOpacity(0.05),
                    ),
                  ),
                ),

                // ── Blob bottom-right ──
                Positioned(
                  bottom: -60.h,
                  right: -60.w,
                  child: Container(
                    width: 220.w,
                    height: 220.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor.withOpacity(0.06),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 160.h,
                  right: 10.w,
                  child: Container(
                    width: 30.w,
                    height: 30.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold600.withOpacity(0.12),
                    ),
                  ),
                ),

                // ── Main Content ──
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: isDesktop ? 700 : double.infinity),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                            // Custom Header Row with Title and Back Button
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: SizedBox(
                                width: double.infinity,
                                height: 50.h,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Centered Title
                                    Text(
                                      'ساحة التحديات',
                                      style: TextStyle(
                                        fontSize: 22.sp,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'SomarSans',
                                        color: isDark ? Colors.white : AppColors.textBlack,
                                      ),
                                    ),
                                    // Absolute Left Back Button
                                    Positioned(
                                      left: 0,
                                      child: IconButton(
                                        icon: Container(
                                          padding: EdgeInsets.all(10.r),
                                          decoration: BoxDecoration(
                                            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(14.r),
                                          ),
                                          child: Icon(
                                            Icons.arrow_back_ios_new_rounded,
                                            size: 20.sp,
                                            color: isDark ? Colors.white : AppColors.primaryColor,
                                          ),
                                        ),
                                        onPressed: () => Navigator.of(context).pop(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 32.h),

                            // ── HERO CHARACTER ──
                            Container(
                              width: 200.w,
                              height: 200.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryColor.withOpacity(0.05),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryColor.withOpacity(0.12),
                                    blurRadius: 60,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const DynamicAppAsset(
                                assetKey: 'challenge_character',
                                fallbackAssetPath: SVGs.refiqBoarding,
                                type: AppAssetType.svg,
                              ),
                            )
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .moveY(
                                    begin: 0,
                                    end: -20,
                                    duration: 3000.ms,
                                    curve: Curves.easeInOut),

                            SizedBox(height: 32.h),

                            // ── Title ──
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '⚔️ الاستعداد للمعركة',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 34.sp,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'SomarSans',
                                      color: isDark ? Colors.white : AppColors.textBlack,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.3, end: 0),

                            SizedBox(height: 12.h),
                            
                            Text(
                              'اختر كيف تريد مواجهة منافسك اليوم',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: isDark ? Colors.white70 : AppColors.greyColor,
                                fontFamily: 'SomarSans',
                              ),
                            ).animate(delay: 200.ms).fadeIn(),

                             SizedBox(height: 48.h),

                            // ── ENTER BUTTON ──
                            GestureDetector(
                              onTap: _handleEnter,
                              onTapDown: _onTapDown,
                              onTapUp: _onTapUp,
                              onTapCancel: _onTapCancel,
                              child: AnimatedScale(
                                scale: _pressing ? 0.98 : 1.0,
                                duration: const Duration(milliseconds: 110),
                                curve: Curves.easeOut,
                                child: Container(
                                  width: isDesktop ? 600.w : double.infinity,
                                  height: 62.h,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(22.r),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.15),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF10B981).withOpacity(0.25),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.rocket_launch_rounded,
                                                  color: Colors.white, size: 24)
                                              .animate(onPlay: (c) => c.repeat(reverse: true))
                                              .moveY(begin: 0, end: -3, duration: 1200.ms),
                                          SizedBox(width: 12.w),
                                          Text(
                                            'ادخل الساحة!',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 19.sp,
                                              fontWeight: FontWeight.w900,
                                              fontFamily: 'SomarSans',
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ).animate(delay: 800.ms).fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0),

                            SizedBox(height: 50.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ──────────────────────────────
//  Chip widget
// ──────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final displayColor = isDark ? color.withOpacity(0.9) : color;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: displayColor.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: displayColor.withOpacity(isDark ? 0.3 : 0.2),
          width: 1.2,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : color,
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w900,
          fontFamily: 'SomarSans',
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
//  Portal Overlay  –  single AnimationController, smooth
// ══════════════════════════════════════════════════════
void _showPortalOverlay(BuildContext context, VoidCallback onComplete) {
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _PortalOverlay(
      onDone: () {
        onComplete();
        Future.delayed(const Duration(milliseconds: 350), () {
          if (entry.mounted) entry.remove();
        });
      },
    ),
  );
  Overlay.of(context, rootOverlay: true).insert(entry);
}

class _PortalOverlay extends StatefulWidget {
  final VoidCallback onDone;
  const _PortalOverlay({required this.onDone});
  @override
  State<_PortalOverlay> createState() => _PortalOverlayState();
}

class _PortalOverlayState extends State<_PortalOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  // All animations derived from one controller via Interval — no jank
  late Animation<double> _ring1; // 0.00 → 0.55
  late Animation<double> _ring2; // 0.10 → 0.60
  late Animation<double> _ring3; // 0.20 → 0.68
  late Animation<double> _particles; // 0.05 → 0.68
  late Animation<double> _fill; // 0.52 → 1.00

  final Random _rnd = Random();
  late List<_Particle> _ptList;

  Animation<double> _iv(double b, double e, Curve c) => CurvedAnimation(
        parent: _ctrl,
        curve: Interval(b, e, curve: c),
      );

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );

    _ring1 = _iv(0.00, 0.55, Curves.easeOut);
    _ring2 = _iv(0.10, 0.60, Curves.easeOut);
    _ring3 = _iv(0.20, 0.68, Curves.easeOut);
    _particles = _iv(0.05, 0.68, Curves.easeOut);
    _fill = _iv(0.52, 1.00, Curves.easeInOut);

    // Teal-only particles — elegant & matching the page
    _ptList = List.generate(38, (_) {
      final angle = _rnd.nextDouble() * 2 * pi;
      final speed = 0.35 + _rnd.nextDouble() * 1.0;
      return _Particle(
        dx: cos(angle) * speed,
        dy: sin(angle) * speed,
        size: 2 + _rnd.nextDouble() * 8,
        color: Color.lerp(
          AppColors.primaryColor,
          AppColors.gold600,
          _rnd.nextDouble(),
        )!,
        opacity: 0.5 + _rnd.nextDouble() * 0.5,
      );
    });

    _ctrl.forward().then((_) async {
      if (mounted) widget.onDone();
    });

    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 950), () {
      if (mounted) HapticFeedback.mediumImpact();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final maxR = size.longestSide * 1.25;

    final bgColor = isDark ? const Color(0xFF0B1120) : const Color(0xFFECFDF5);
    final rippleColor1 = isDark ? const Color(0xFF0B1120) : const Color(0xFFD1FAE5);
    final rippleColor2 = isDark ? const Color(0xFF0D1830) : const Color(0xFFF0FDF4);
    final rippleColor3 = isDark ? const Color(0xFF111827) : Colors.white;

    final portalGradient = isDark
        ? [const Color(0xFF111827), const Color(0xFF0B1120), const Color(0xFF060C18)]
        : [Colors.white, const Color(0xFFF1F5F9), const Color(0xFFE0F2FE)];

    return Material(
      type: MaterialType.transparency,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final fillR = _fill.value * maxR;
          return Stack(
            children: [
              // ── Instant full-screen background (matching theme) ──
              Positioned.fill(
                child: ColoredBox(color: bgColor),
              ),

              // ── Three ripple rings ──
              _ripple(size, _ring1.value, maxR * 0.50, rippleColor1, 3.5),
              _ripple(size, _ring2.value, maxR * 0.68, rippleColor2, 2.5),
              _ripple(size, _ring3.value, maxR * 0.85, rippleColor3, 1.5),

              // ── Teal particles ──
              Positioned.fill(
                child: CustomPaint(
                  painter: _ParticlesPainter(
                    particles: _ptList,
                    progress: _particles.value,
                  ),
                ),
              ),

              // ── Portal filling screen ──
              if (_fill.value > 0)
                Positioned(
                  left: size.width / 2 - fillR,
                  top: size.height / 2 - fillR,
                  child: Container(
                    width: fillR * 2,
                    height: fillR * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: portalGradient,
                        stops: const [0.0, 0.55, 1.0],
                        radius: 0.9,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _ripple(Size size, double progress, double maxRadius, Color color, double baseWidth) {
    if (progress <= 0) return const SizedBox.shrink();
    final r = progress * maxRadius;
    // Fast fade-in, gradual fade-out
    final opacity = (progress < 0.2 ? progress / 0.2 : 1 - (progress - 0.2) / 0.8).clamp(0.0, 1.0);

    return Positioned(
      left: size.width / 2 - r,
      top: size.height / 2 - r,
      child: Container(
        width: r * 2,
        height: r * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Solid filled dark wave — no stroke, just filled ink
          color: color.withOpacity(opacity * 0.50),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(opacity * 0.25),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────
//  Particle model
// ──────────────────────────────
class _Particle {
  final double dx, dy, size, opacity;
  final Color color;
  const _Particle({
    required this.dx,
    required this.dy,
    required this.size,
    required this.color,
    required this.opacity,
  });
}

// ──────────────────────────────
//  Particle painter
// ──────────────────────────────
class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  const _ParticlesPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final cx = size.width / 2;
    final cy = size.height / 2;

    for (final p in particles) {
      final px = cx + p.dx * progress * size.width * 0.44;
      final py = cy + p.dy * progress * size.height * 0.44;
      // Fade out in last 35%
      final fade = progress < 0.65 ? 1.0 : 1 - (progress - 0.65) / 0.35;
      final alpha = (p.opacity * fade).clamp(0.0, 1.0);
      final r = p.size * (1 + progress * 0.5);

      // Soft glow halo
      canvas.drawCircle(
        Offset(px, py),
        r * 2.4,
        Paint()
          ..color = p.color.withOpacity(alpha * 0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
      );
      // Crisp core dot
      canvas.drawCircle(
        Offset(px, py),
        r,
        Paint()..color = p.color.withOpacity(alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter old) => old.progress != progress;
}
